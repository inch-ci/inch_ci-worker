require 'yaml'

module InchCI
  module Worker
    module ListTags
      class Report < Struct.new(:tag_list)
        def to_yaml
          to_hash.to_yaml
        end

        private

        def to_hash
          {'tags' => tag_list}
        end
      end
    end
  end
end
