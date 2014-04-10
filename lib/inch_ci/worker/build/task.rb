require 'inch'
require 'repomen'

require_relative 'result'
require_relative 'report'

module InchCI
  module Worker
    module Build
      class Task
        def initialize(url, branch_name = "master")
          started_at = Time.now
          @result = build(url, branch_name)
          @result.finished_at = Time.now
          @result.started_at = started_at
          puts Report.new(@result).to_yaml
        end

        private

        def build(url, branch_name)
          @url = url
          if retrieve_repo
            repo.change_branch(branch_name)
            @codebase = parse_codebase(repo.path)
            ResultSuccess.new(repo, branch_name, @codebase.objects)
          else
            ResultRetrieveFail.new(repo, branch_name, nil)
          end
        end

        def parse_codebase(path)
          YARD::Config.options[:safe_mode] = true
          ::Inch::Codebase.parse(path)
        end

        def repo
          @repo ||= Repomen.retrieve(@url)
        end

        # @return [Repomen::Retriever,nil] either the retrieved repo or +nil+
        def retrieve_repo
          repo.retrieved? ? repo : nil
        end
      end
    end
  end
end
