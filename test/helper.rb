$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'test/unit'
require 'mocha/test_unit'
require 'saddler/reporter/support/git'
REPO_PATH = File.expand_path('../fixtures', __FILE__)
