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

          test '#remote_urls' do
            assert do
              @repository.remote_urls \
                == [
                  'git://github.com/libgit2/libgit2.git',
                  'git://github.com/libgit2/rugged.git'
                ]
            end
          end

          sub_test_case 'fixture and #slug' do
            test 'fixture #slug' do
              assert do
                @repository.slug == 'libgit2/libgit2'
              end
            end
          end

          sub_test_case 'stub and #slug' do
            test 'stub #slug' do
              @repository.expects(:remote_urls).returns([
                'git@github.com:packsaddle/example-ruby-travis-ci.git'
              ])
              assert do
                @repository.slug == 'packsaddle/example-ruby-travis-ci'
              end
            end
            test 'stub2 #slug' do
              @repository.expects(:remote_urls).returns([
                'git://github.com/libgit2/libgit2.git',
                'git://github.com/libgit2/rugged.git'
              ])
              assert do
                @repository.slug == 'libgit2/libgit2'
              end
            end
          end
        end
      end
    end
  end
end
