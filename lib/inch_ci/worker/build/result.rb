module InchCI
  module Worker
    module Build
      class Result < Struct.new(:repo, :branch_name, :latest_revision, :objects)
        extend Forwardable

        def_delegators :repo, :url
        def_delegators :repo, :service_name, :user_name, :repo_name
        def_delegators :repo, :revision_author_name
        def_delegators :repo, :revision_author_email
        def_delegators :repo, :revision_authored_at

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

        def tag_uid
          repo.tag.empty? ? nil : repo.tag
        end
      end

      class ResultSuccess < Result
        def status
          'success'
        end
      end

      class ResultFail < Result
        def revision_uid; nil; end
        def revision_author_name; nil; end
        def revision_author_email; nil; end
        def revision_authored_at; nil; end
        def tag_uid; nil; end
        def service_name; nil; end
        def user_name; nil; end
        def repo_name; nil; end
        def status
          'failed'
        end
      end

      class ResultRetrieverFailed < ResultFail
        def status
          'retriever_failed'
        end
      end

      class ResultChangeBranchFailed < ResultFail
        def status
          'change_branch_failed'
        end
      end

      class ResultCheckoutRevisionFailed < ResultFail
        def status
          'checkout_revision_failed'
        end
      end

      class ResultParserFailed < ResultFail
        def status
          'parser_failed'
        end
      end
    end
  end
end
