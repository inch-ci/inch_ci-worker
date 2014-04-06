require 'simplecov'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'minitest/autorun'
require 'bundler'
Bundler.require
require 'inch_ci/worker'
