require_relative 'helper'

module Saddler
  module Reporter
    module Support
      module Git
        class TestGitRepository < Test::Unit::TestCase
          def setup
            @repository = Repository.new(
              REPO_PATH,
              repository: File.join(REPO_PATH, 'testrepo.git'),
              index: File.join(REPO_PATH, 'testrepo.git', 'index')
            )
          end

          test 'version' do
            assert do
              !::Saddler::Reporter::Support::Git::VERSION.nil?
            end
          end

          test '#current_branch' do
            assert do
              @repository.current_branch == 'master'
            end
          end
        end
      end
    end
  end
end
