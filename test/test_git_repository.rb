require_relative 'helper'

module Saddler
  module Reporter
    module Support
      module Git
        class TestGitRepository < Test::Unit::TestCase
          extend ::EnvBranch::TestHelper
          def self.startup
            stash_env_branch
          end

          def self.shutdown
            restore_env_branch
          end

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
              @repository.remote_urls == [
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
            test 'stub1 #slug' do
              @repository.expects(:remote_urls).returns(
                [
                  'git@github.com:packsaddle/example-ruby-travis-ci.git'
                ]
              )
              assert do
                @repository.slug == 'packsaddle/example-ruby-travis-ci'
              end
            end
            test 'stub2 #slug' do
              @repository.expects(:remote_urls).returns(
                [
                  'git://github.com/libgit2/libgit2.git',
                  'git://github.com/libgit2/rugged.git'
                ]
              )
              assert do
                @repository.slug == 'libgit2/libgit2'
              end
            end
            test 'stub3 #slug' do
              @repository.expects(:remote_urls).returns(
                [
                  'git@github.com:sanemat/sanemat.github.com.git'
                ]
              )
              assert do
                @repository.slug == 'sanemat/sanemat.github.com'
              end
            end
            test 'stub4 #slug' do
              @repository.expects(:remote_urls).returns(
                [
                  'https://github.com/sanemat/sanemat.github.com.git'
                ]
              )
              assert do
                @repository.slug == 'sanemat/sanemat.github.com'
              end
            end
            test 'stub5 #slug' do
              @repository.expects(:remote_urls).returns(
                [
                  'github.com:/sanemat/sanemat.github.com.git'
                ]
              )
              assert do
                @repository.slug == 'sanemat/sanemat.github.com'
              end
            end
          end

          sub_test_case 'stub remote develop and #tracking_branch_name' do
            test '#tracking_branch_name' do
              @repository.expects(:config).returns(
                'user.name' => 'example',
                'user.email' => 'who@example.com',
                'push.default' => 'simple',
                'remote.origin.url' => 'git@github.com:example/example.com.git',
                'remote.origin.fetch' => '+refs/heads/*:refs/remotes/origin/*',
                'branch.develop.remote' => 'origin',
                'branch.develop.merge' => 'refs/heads/develop',
                'branch.spike/no-valid-master.remote' => 'origin',
                'branch.spike/no-valid-master.merge' => 'refs/heads/develop')
              assert do
                @repository.git_tracking_branch_name == 'develop'
              end
            end
          end

          sub_test_case 'stub remote master and #tracking_branch_name' do
            test '#tracking_branch_name' do
              @repository.expects(:config).returns(
                'user.name' => 'example',
                'user.email' => 'who@example.com',
                'push.default' => 'simple',
                'remote.origin.url' => 'git@github.com:example/example.com.git',
                'remote.origin.fetch' => '+refs/heads/*:refs/remotes/origin/*',
                'branch.develop.remote' => 'origin',
                'branch.develop.merge' => 'refs/heads/master',
                'branch.spike/no-valid-master.remote' => 'origin',
                'branch.spike/no-valid-master.merge' => 'refs/heads/master')
              assert do
                @repository.git_tracking_branch_name == 'master'
              end
            end
          end

          sub_test_case 'stub no remote and #tracking_branch_name' do
            test '#tracking_branch_name' do
              @repository.expects(:config).returns(
                'user.name' => 'example',
                'user.email' => 'who@example.com',
                'push.default' => 'simple',
                'remote.origin.url' => 'git@github.com:example/example.com.git',
                'remote.origin.fetch' => '+refs/heads/*:refs/remotes/origin/*')
              assert do
                @repository.git_tracking_branch_name.nil?
              end
            end
          end
        end
      end
    end
  end
end
