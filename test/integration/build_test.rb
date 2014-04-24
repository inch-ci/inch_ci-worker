require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

describe ::InchCI::Worker::Build do
  let(:described_class) { ::InchCI::Worker::Build::Task }
  let(:branch_name) { 'master' }
  let(:url) { 'git@bitbucket.org:atlassian_tutorial/helloworld.git' }
  let(:incorrect_url) { 'git@bitbucket.org:atlassian_tutorial/helloworld123.git' }

  #
  # Good scenarios
  #

  it 'should retrieve the repo' do
    out, err = capture_io do
      @task = described_class.new(url, branch_name)
    end
    refute out.empty?
    assert_match /status: success/, out
    assert err.empty?
  end

  it 'should retrieve the repo and checkout revision' do
    skip # helloworld doesnot have tags
    # TODO: make own helloworld repo
    out, err = capture_io do
      @task = described_class.new(url, branch_name, 'v0.1.0')
    end
    refute out.empty?
    assert_match /status: success/, out
    assert err.empty?
  end

  #
  # Deal with invalid parameters
  #

  it "should not retrieve non-existing branch in repo" do
    out, err = capture_io do
      @task = described_class.new(url, 'somebranch')
    end
    refute out.empty?
    assert_match /status: failed:change_branch/, out
  end

  it "should not retrieve non-existing revision in repo" do
    out, err = capture_io do
      @task = described_class.new(url, branch_name, 'vX.X.X')
    end
    refute out.empty?
    assert_match /status: failed:checkout_revision/, out
  end

  #
  # Deal with not existing repos, whatever the parameters are
  #

  it "should not retrieve non-existing repo" do
    out, err = capture_io do
      @task = described_class.new(incorrect_url, branch_name)
    end
    refute out.empty?
    assert_match /status: failed:retriever/, out
  end

  it "should not retrieve non-existing branch in non-existing repo" do
    out, err = capture_io do
      @task = described_class.new(incorrect_url, 'somebranch')
    end
    refute out.empty?
    assert_match /status: failed:retriever/, out
  end

  it "should not retrieve non-existing revision in non-existing repo" do
    out, err = capture_io do
      @task = described_class.new(incorrect_url, branch_name, 'vX.X.X')
    end
    refute out.empty?
    assert_match /status: failed:retriever/, out
  end

  #
  # Deal with errors thrown by Inch itself
  #

  module ::Inch::Codebase
    class << self
      alias :parse_original :parse
    end
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
    assert_match /status: failed:parser/, out

    # Let's repair the Parser
    def codebase.parse(*args)
      parse_original(*args)
    end
  end
end
