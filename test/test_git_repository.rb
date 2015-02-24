require_relative 'helper'

module Saddler
  module Reporter
    module Support
      module Git
        class TestGitRepository < Test::Unit::TestCase
          test 'version' do
            assert do
              !::Saddler::Reporter::Support::Git::VERSION.nil?
            end
          end
        end
      end
    end
  end
end
