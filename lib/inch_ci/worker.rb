require 'repomen'

# Set the directory where checked out repos are kept
Repomen.config.work_dir = ENV['REPOMEN_WORK_DIR'] || File.join(__dir__, '..', '..', 'tmp')

# Check out the whole history
Repomen.config.only_last_revision = false

module InchCI
  module Worker
  end
end

require 'inch_ci/worker/build'
require 'inch_ci/worker/build_json'
require 'inch_ci/worker/list_tags'
