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
            slug_regex = %r{\A/(?<slug>.*?)(?:\.git)?\Z}
            remote_urls.map do |url|
              uri = GitCloneUrl.parse(url)
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
            merging_object.sha
          end

          # This for GitHub pull request diff file.
          # if head is commit which already merged,
          # head's parent objects include merging object
          # and (master or origin/master)
          def merging_object
            return head unless merge_commit?(head)
            commit = head.parents.select do |parent|
              ![tracking.sha, origin_tracking.sha].include?(parent.sha)
            end
            return commit.last if commit.count == 1
            head # fallback
          end

          def tracking
            @git.object(tracking_branch_name)
          end

          def origin_tracking
            @git.object("origin/#{tracking_branch_name}")
          end

          def config
            @git.config
          end

          # http://stackoverflow.com/questions/4950725/how-do-i-get-git-to-show-me-which-branches-are-tracking-what
          # { "branch.spike/no-valid-master.merge" => "refs/heads/develop" }
          # => "develop"
          def tracking_branch_name
            config
              .select { |k, _| /\Abranch.*merge\Z/ =~ k }
              .values
              .map do |v|
              match = %r{\Arefs/heads/(.*)\Z}.match(v)
              match ? match[1] : nil
            end.compact
              .uniq
              .shift
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
            elsif ENV['CIRCLE_BRANCH']
              ENV['CIRCLE_BRANCH']
            end
          end
        end
      end
    end
  end
end
