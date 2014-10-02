require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

describe ::InchCI::Worker::BuildJSON do
  let(:described_class) { ::InchCI::Worker::BuildJSON::Task }
  let(:filename) { File.expand_path(File.dirname(__FILE__) + '/../fixtures/elixir/inch_ex.json') }

  #
  # Good scenarios
  #

  it 'should retrieve the repo' do
    out, err = capture_io do
      @task = described_class.new(filename)
    end
    refute out.empty?
    assert_match /status: success/, out
    assert err.empty?
  end
end
