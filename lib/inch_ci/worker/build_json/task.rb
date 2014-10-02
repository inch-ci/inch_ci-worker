require 'json'
require 'inch'
require 'inch/cli'

module InchCI
  module Worker
    module BuildJSON
      class Task
        attr_reader :json

        def initialize(filename)
          @json = BuildJSON.json(filename)
          @work_dir = Dir.mktmpdir

          started_at = Time.now
          @result = build(filename)
          @result.finished_at = Time.now
          @result.started_at = started_at
          puts Build::Report.new(@result).to_yaml
        end

        private

        # @param info [#service_name,#user_name,#repo_name]
        def badge_in_readme?(info)
          Build::BadgeDetector.in_readme?(repo, info)
        end

        def build(filename)
          language    = json.language
          branch_name = json.branch_name
          revision    = json.revision
          nwo         = json.nwo
          @url        = json.url
          latest_revision  = true # TODO: make truthful

          if retrieve_repo
            if repo.change_branch(branch_name, true)
              if repo.checkout_revision(revision)
                if @codebase = parse_codebase(language, filename, repo.path)
                  result = Build::ResultSuccess.new(repo, branch_name, latest_revision, @codebase.objects)
                  result.badge_in_readme = badge_in_readme?(result)
                  result
                else
                  Build::ResultParserFailed.new(repo, branch_name, latest_revision, nil)
                end
              else
                Build::ResultCheckoutRevisionFailed.new(repo, branch_name, latest_revision, nil)
              end
            else
              Build::ResultChangeBranchFailed.new(repo, branch_name, latest_revision, nil)
            end
          else
            Build::ResultRetrieverFailed.new(repo, branch_name, latest_revision, nil)
          end
        end

        def parse_codebase(language, filename, path)
          begin
            ::Inch::Codebase.parse(path, to_config(language, filename, path))
          rescue Exception => e
            warn e.inspect
            nil
          end
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
        # @return [Config::Codebase]
        def to_config(language, filename, path)
          config = ::Inch::Config.for(language, path).codebase
          config.read_dump_file = filename
          config
        end
      end
    end
  end
end
