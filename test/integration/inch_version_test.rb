require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

describe ::InchCI::Worker::Build do
  let(:described_class) { ::InchCI::Worker::Build::Task }
  let(:branch_name) { 'master' }
  let(:url) { 'https://github.com/rrrene/sparkr.git' }

  #
  # Good scenario
  #

  it 'should retrieve the repo' do
    out, err = capture_io do
      @task = described_class.new(url, branch_name)
    end
    refute out.empty?
    assert_match /status: success/, out
    assert_match /inch_version: \d+\.\d+\.\d+/, out
    assert err.empty?
  end
end
