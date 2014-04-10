require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

describe ::InchCI::Worker::Build do
  let(:described_class) { ::InchCI::Worker::Build::Task }
  let(:branch_name) { 'master' }
  let(:url) { 'git@bitbucket.org:atlassian_tutorial/helloworld.git' }
  let(:incorrect_url) { 'git@bitbucket.org:atlassian_tutorial/helloworld123.git' }

  module ::Inch::Codebase
    class << self
      alias :parse_original :parse
    end
  end

  it 'should retrieve the repo' do
    out, err = capture_io do
      @task = described_class.new(url, branch_name)
    end
    refute out.empty?
    assert_match /status: success/, out
    assert err.empty?
  end

  it "should not retrieve non-existing repo" do
    out, err = capture_io do
      @task = described_class.new(incorrect_url, branch_name)
    end
    refute out.empty?
    assert_match /status: retriever_failed/, out
  end

  it "should not retrieve error throwing repo" do
    # Patch the Parser to fail
    codebase = ::Inch::Codebase
    def codebase.parse(*args)
      raise "Vending machine is broken!"
    end

    out, err = capture_io do
      @task = described_class.new(url, branch_name)
    end
    refute out.empty?
    assert_match /status: parser_failed/, out

    # Let's repair the Parser
    def codebase.parse(*args)
      parse_original(*args)
    end
  end
end
