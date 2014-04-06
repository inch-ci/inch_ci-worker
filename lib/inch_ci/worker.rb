require "inch_ci/worker/build"
require "inch_ci/worker/version"

require 'repomen'

# Set the directory where checked out repos are kept
Repomen.config.work_dir = ENV['REPOMEN_WORK_DIR'] || File.join(__dir__, '..', "tmp")

module InchCI
  module Worker
  end
end
