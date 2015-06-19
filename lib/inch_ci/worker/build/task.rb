require 'tmpdir'
require 'inch'
require 'inch/cli'
require 'repomen'

require 'inch_ci/worker/build/result'
require 'inch_ci/worker/build/report'
require 'inch_ci/worker/build/badge_detector'

module InchCI
  module Worker
    module Build
      class Task
        def initialize(url, branch_name = 'master', revision = nil, language = nil)
          @work_dir = Dir.mktmpdir
          if revision.nil?
            revision = 'HEAD'
            @latest_revision = true
          end
          started_at = Time.now
          @result = build(url, branch_name, revision, !!@latest_revision, language)
          @result.finished_at = Time.now
          @result.started_at = started_at
          puts Report.new(@result).to_yaml
        ensure
          FileUtils.remove_entry(@work_dir) unless @work_dir.nil?
        end

        private

        # @param info [#service_name,#user_name,#repo_name]
        def badge_in_readme?(info)
          BadgeDetector.in_readme?(repo, info)
        end

        def build(url, branch_name, revision, latest_revision, language)
          @url = url
          if retrieve_repo
            checkout_cmd = branch_name == "master" ? "master" : "--track origin/#{branch_name}"
            if repo.change_branch(checkout_cmd, true)
              if repo.checkout_revision(revision)
                if @codebase = parse_codebase(language, repo.path)
                  result = ResultSuccess.new(repo, branch_name, latest_revision, @codebase.objects)
                  result.badge_in_readme = badge_in_readme?(result)
                  result
                else
                  ResultParserFailed.new(repo, branch_name, latest_revision, nil)
                end
              else
                ResultCheckoutRevisionFailed.new(repo, branch_name, latest_revision, nil)
              end
            else
              ResultChangeBranchFailed.new(repo, branch_name, latest_revision, nil)
            end
          else
            ResultRetrieverFailed.new(repo, branch_name, latest_revision, nil)
          end
        end

        def parse_codebase(language, path)
          if language.to_s.downcase == 'javascript'
            parse_javascript_codebase(path)
          else
            parse_ruby_codebase(path)
          end
        end

        def parse_javascript_codebase(path)
          dump_file = prepare_javascript_codebase(path)
          return if dump_file.nil? # this causes ResultParserFailed

          config = to_config(:javascript, path)
          config.read_dump_file = dump_file
          begin
            ::Inch::Codebase.parse(path, config)
          rescue Exception => e
            warn e.inspect
            nil
          end
        end

        def parse_ruby_codebase(path)
          YARD::Config.options[:safe_mode] = true

          begin
            ::Inch::Codebase.parse(path, to_config(:ruby, path))
          rescue Exception => e
            warn e.inspect
            nil
          end
        end

        def prepare_javascript_codebase(path)
          old_path = Dir.pwd
          Dir.chdir path
          `npm install inchjs && inchjs --dry-run`
          Dir.chdir old_path
          dump_file = File.join(path, 'docs.json')
          File.exist?(dump_file) ? dump_file : nil
        end

        def repo
          @repo ||= Repomen::Retriever.new(@url, :work_dir => @work_dir)
        end

        # @return [Repomen::Retriever,nil] either the retrieved repo or +nil+
        def retrieve_repo
          repo.retrieved? ? repo : nil
        end

        # Creates a Config::Codebase object and returns it
        # (merges relevant values of a given +options+ object before).
        #
        # @param options [Options::Base]
        # @return [Config::Codebase]
        def to_config(language, path)
          config = ::Inch::Config.for(language, path).codebase

          if language == :ruby
            helper = YardOptsWrapper.new(path)
            config.included_files = helper.paths unless helper.paths.empty?
            unless helper.excluded.empty?
              config.excluded_files = helper.excluded
            end
          end

          config
        end

        # Utility class to extract .yardopts from repo dir
        class YardOptsWrapper
          YARD_DEFAULT_FILES = ["{lib,app}/**/*.rb", "ext/**/*.c"]

          attr_reader :paths, :excluded

          def initialize(path)
            old_path = Dir.pwd
            Dir.chdir path
            wrapper = ::Inch::CLI::YardoptsHelper::YardoptsWrapper.new
            wrapper.parse_arguments()
            @paths = wrapper.files == YARD_DEFAULT_FILES ? [] : wrapper.files
            @excluded = wrapper.excluded
            Dir.chdir old_path
          end
        end

      end
    end
  end
end
