require 'inch_ci/worker/build_json/task'

module InchCI
  module Worker
    module BuildJSON
      def self.json(filename)
        JSONDump.new(filename)
      end

      class JSONDump
        attr_reader :language, :branch_name, :revision, :nwo, :url

        def initialize(filename)
          contents = File.read(filename, :encoding => 'utf-8')
          @json = JSON[contents]
          @language    = @json['language']
          @branch_name = @json['branch_name'] || @json['travis_branch']
          @revision    = @json['revision'] || @json['travis_commit']
          @nwo         = @json['nwo'] || @json['travis_repo_slug']
          @url         = @json['git_repo_url']
        end

        def travis?
          !@json['travis'].nil?
        end

        def to_h(include_objects: true)
          h = @json.dup
          h.delete('objects') unless include_objects
          h
        end
      end
    end
  end
end
