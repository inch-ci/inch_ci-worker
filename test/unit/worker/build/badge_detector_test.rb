require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

describe ::InchCI::Worker::Build::BadgeDetector do
  let(:described_class) { ::InchCI::Worker::Build::BadgeDetector }
  let(:info_mock) {
    OpenStruct.new(:service_name => 'github', :user_name => 'user_name', :repo_name => 'repo_name')
  }
  let(:with_badge) {
    "RepoName\n======\n\n[![Code Climate](https://codeclimate.com/github/user_name/repo_name.png)](https://codeclimate.com/github/user_name/repo_name)\n[![Inline docs](http://inch-ci.org/github/user_name/repo_name.svg?branch=master)](http://inch-ci.org/github/user_name/repo_name)\n\nThink of it like Homebrew for Minecraft.\n\nOf course where every individual projects gets it's own Formula,\n this allowing for mods to declare their runtime dependencies\n and making installing mods more or less painless.\n \n### Requirments\n\nTo run repo_name on your system you a few pieces of software installed. If you use your computer for any sort of development, or your computer runs Mac OS X or any of the main Linux distros, it is likely you already have this software installed. To make sure that your computer is ready to brew Minecraft be sure to check the [wiki page](https://github.com/user_name/repo_name/wiki/Requirements) on requirements for each platform.\n\n### Install\n\nMuch like the inspiring project of this project, installation is simple.\n\nRun this line of code in your system's command prompt and let it walk you through what it is doing.\n\n> On Mac OS X or any other system that uses curl:\n```\nruby -e \"$(curl -fsSL https://raw.github.com/user_name/repo_name/go/install)\"\n```\n\n> On most Linux distros:\n```\nruby -e \"$(wget -O- https://raw.github.com/user_name/repo_name/go/install)\"\n```\n\n> Using Windows PowerShell\n```\n$storageDir = #env.TEMP\n$webclient = New-Object System.Net.WebClient\n$url = \"https://raw.github.com/user_name/repo_name/go/install\"\n$file = \"$storageDir\\repo_name-install\"\n$webclient.DownloadFile($url,$file)\nStart-Process \"$storageDir\\repo_name-install\"\n```\n"
  }
  let(:with_badge_single_line) {
    "[![Code Climate](https://codeclimate.com/github/user_name/repo_name.png)](https://codeclimate.com/github/user_name/repo_name)\n\n\n[![Inline docs](http://inch-ci.org/github/user_name/repo_name.png?branch=master)](http://inch-ci.org/github/user_name/repo_name)"
  }

  it "should detect badge" do
    [with_badge, with_badge_single_line].each do |str|
      assert described_class.new(str, info_mock).detected?
    end
  end
end
