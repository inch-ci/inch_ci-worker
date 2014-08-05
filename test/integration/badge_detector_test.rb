require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

describe ::InchCI::Worker::Build do
  let(:described_class) { ::InchCI::Worker::Build::Task }
  let(:branch_name) { 'master' }
  let(:url) { 'https://github.com/rrrene/inch.git' }
  let(:incorrect_url) { 'https://github.com/rrrene/tipsy.hovercard.git' }

  #
  # Good scenario
  #

  it 'should show badge in readme' do
    out, err = capture_io do
      @task = described_class.new(url, branch_name)
    end
    refute out.empty?
    assert_match /status: success/, out
    assert_match /badge_in_readme: true/, out
    assert err.empty?
  end

  #
  # Bad scenario
  #

  it 'should show no badge in readme' do
    out, err = capture_io do
      @task = described_class.new(incorrect_url, branch_name)
    end
    refute out.empty?
    assert_match /status: success/, out
    assert_match /badge_in_readme: false/, out
    assert err.empty?
  end
end
