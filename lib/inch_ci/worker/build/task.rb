require 'tmpdir'
require 'inch'
require 'repomen'

require 'inch_ci/worker/build/result'
require 'inch_ci/worker/build/report'
require 'inch_ci/worker/build/badge_detector'

module InchCI
  module Worker
    module Build
      class Task
        def initialize(url, branch_name = 'master', revision = nil)
          @work_dir = Dir.mktmpdir
          if revision.nil?
            revision = 'HEAD'
            @latest_revision = true
          end
          started_at = Time.now
          @result = build(url, branch_name, revision, !!@latest_revision)
          @result.finished_at = Time.now
          @result.started_at = started_at
          puts Report.new(@result).to_yaml
        ensure
          FileUtils.remove_entry(@work_dir) unless @work_dir.nil?
        end

        private

        def build(url, branch_name, revision, latest_revision)
          @url = url
          if retrieve_repo
            if repo.change_branch(branch_name, true)
              if repo.checkout_revision(revision)
                if @codebase = parse_codebase(repo.path)
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

        # @param info [#service_name,#user_name,#repo_name]
        def badge_in_readme?(info)
          BadgeDetector.in_readme?(repo, info)
        end

        def parse_codebase(path)
          YARD::Config.options[:safe_mode] = true
          begin
            ::Inch::Codebase.parse(path)
          rescue Exception => e
            warn e
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
      end
    end
  end
end
