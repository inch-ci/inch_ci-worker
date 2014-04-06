require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

describe ::InchCI::Worker::Build do
  let(:described_class) { ::InchCI::Worker::Build::Task }
  let(:branch_name) { 'master' }
  let(:url) { "git@bitbucket.org:atlassian_tutorial/helloworld.git" }
  let(:incorrect_url) { "git@bitbucket.org:atlassian_tutorial/helloworld123.git" }

  it "should retrieve the repo" do
    out, err = capture_io do
      @task = described_class.new(url, branch_name)
    end
    refute out.empty?
    assert_match /status: success/, out
    assert err.empty?
  end

  it "should retrieve the repo" do
    out, err = capture_io do
      @task = described_class.new(incorrect_url, branch_name)
    end
    refute out.empty?
    assert_match /status: fail_retrieve/, out
  end
end
