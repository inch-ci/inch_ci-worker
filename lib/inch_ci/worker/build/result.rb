module InchCI
  module Worker
    module Build
      class Result < Struct.new(:repo, :branch_name, :objects)
        extend Forwardable

        def_delegators :repo, :url
        def_delegators :repo, :service_name, :user_name, :repo_name

        attr_accessor :started_at
        attr_accessor :finished_at
        attr_writer :status

        def duration
          finished_at - started_at
        end

        def revision_uid
          repo.revision
        end

        def status
          @status || 'error'
        end
      end

      class ResultSuccess < Result
        def status
          'success'
        end
      end

      class ResultFail < Result
        def revision_uid; nil; end
        def service_name; nil; end
        def user_name; nil; end
        def repo_name; nil; end
        def status
          'fail'
        end
      end

      class ResultRetrieveFail < ResultFail
        def status
          'fail_retrieve'
        end
      end
    end
  end
end
