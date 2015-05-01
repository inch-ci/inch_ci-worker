module InchCI
  module Worker
    module Build
      class BadgeDetector
        def self.in_readme?(repo, info)
          if filename = find_readme(repo)
            contents = File.read(filename, :encoding => 'utf-8')
            new(contents, info).detected?
          else
            false
          end
        end

        # @return [String] filename
        def self.find_readme(repo)
          Dir[File.join(repo.path, '*.*')].sort.detect do |f|
            File.basename(f) =~ /\Areadme\./i
          end
        end

        def initialize(contents, info)
          @contents = contents
          @pattern = Regexp.escape("inch-ci.org/#{info.service_name}/#{info.user_name}/#{info.repo_name}")
        end

        def detected?
          !!( @contents =~ /#{@pattern}/mi )
        end
      end
    end
  end
end