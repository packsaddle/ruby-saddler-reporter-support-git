module Saddler
  module Reporter
    module Support
      module Git
        class Repository
          attr_reader :git

          def initialize(path, options = {})
            @git = ::Git.open(path, options)
          end

          def slug
            slug_regex = %r{\A/?(?<slug>.*?)(?:\.git)?\Z}
            remote_urls.map do |url|
              uri = Addressable::URI.parse(url)
              match = slug_regex.match(uri.path)
              match[:slug] if match
            end.compact.first
          end

          def remote_urls
            @git
              .remotes
              .map(&:url)
          end

          def current_branch
            env_current_branch || @git.current_branch
          end

          def head
            @git.object('HEAD')
          end

          def merging_sha
            return head.sha unless merge_commit?(head)
          end

          def merge_commit?(commit)
            commit.parents.count == 2
          end

          def push_endpoint
            (env_push_endpoint || 'github.com').chomp('/')
          end

          # e.g. 'github.com'
          # git@github.com:packsaddle/ruby-saddler-reporter-support-git.git
          def env_push_endpoint
            if ENV['PUSH_ENDPOINT']
              ENV['PUSH_ENDPOINT']
            end
          end

          def env_current_branch
            if ENV['CURRENT_BRANCH']
              ENV['CURRENT_BRANCH']
            elsif ENV['TRAVIS_BRANCH']
              ENV['TRAVIS_BRANCH']
            end
          end
        end
      end
    end
  end
end
