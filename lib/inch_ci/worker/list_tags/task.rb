require 'inch'
require 'repomen'

require 'inch_ci/worker/list_tags/report'

module InchCI
  module Worker
    module ListTags
      class Task
        def initialize(url, branch_name = 'master')
          @work_dir = Dir.mktmpdir
          @url = url
          @branch_name = branch_name
          puts Report.new(build_tag_list).to_yaml
        ensure
          FileUtils.remove_entry @work_dir
        end

        private

        def build_tag_list
          if retrieve_repo
            if repo.change_branch(@branch_name, true)
              tag_list
            else
              # ChangeBranchFailed
            end
          else
            # RetrieverFailed
          end
        end

        def repo
          @repo ||= Repomen::Retriever.new(@url, :work_dir => @work_dir)
        end

        # @return [Repomen::Retriever,nil] either the retrieved repo or +nil+
        def retrieve_repo
          repo.retrieved? ? repo : nil
        end

        def tag_list
          Dir.chdir(repo.path) do
            output = `git for-each-ref --sort='taggerdate' refs/tags`
            output.lines.map do |line|
              line.split("\t").last.gsub('refs/tags/', '').chomp
            end
          end
        end
      end
    end
  end
end
