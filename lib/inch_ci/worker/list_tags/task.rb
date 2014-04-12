require 'inch'
require 'repomen'

require_relative 'report'

module InchCI
  module Worker
    module ListTags
      class Task
        def initialize(url, branch_name = 'master')
          @url = url
          @branch_name = branch_name
          puts Report.new(build_tag_list).to_yaml
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
          @repo ||= Repomen.retrieve(@url)
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
