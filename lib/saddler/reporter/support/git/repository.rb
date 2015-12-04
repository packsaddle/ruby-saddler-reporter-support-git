module Saddler
  module Reporter
    module Support
      module Git
        # Git repository support utility for saddler-reporter
        class Repository
          attr_reader :git
          # @!attribute [r] git
          #   @return [::Git] git repository object
          #
          #   @see https://github.com/schacon/ruby-git

          # Build git repository support utility object
          #
          # @param path [String] working_dir
          # @param options [Hash] Git.open options (see ::Git.open)
          #
          # @see https://github.com/schacon/ruby-git
          def initialize(path, options = {})
            @git = ::Git.open(path, options)
          end

          # @return [String] `user/repo` from remote_urls
          def slug
            slug_regex = %r{\A/?(?<slug>.*?)(?:\.git)?\Z}
            remote_urls.map do |url|
              uri = GitCloneUrl.parse(url)
              match = slug_regex.match(uri.path)
              match[:slug] if match
            end.compact.first
          end

          # @return [Array<String>] remote urls
          def remote_urls
            @git
              .remotes
              .map(&:url)
          end

          # @return [String] current branch name
          def current_branch
            env_current_branch || @git.current_branch
          end

          # @return [::Git::Object] git object for `HEAD`
          def head
            @git.object('HEAD')
          end

          # @return [String] merging_object's sha
          def merging_sha
            merging_object.sha
          end

          # This for GitHub pull request diff file.
          # if head is commit which already merged,
          # head's parent objects include merging object
          # and (master or origin/master)
          #
          # @return [::Git::Object] merging object
          def merging_object
            return head unless merge_commit?(head)
            commit = head.parents.select do |parent|
              ![tracking.sha, origin_tracking.sha].include?(parent.sha)
            end
            return commit.last if commit.count == 1
            head # fallback
          end

          # @return [::Git::Object] git object for `tracking_branch_name`
          def tracking
            @git.object(tracking_branch_name)
          end

          # @return [::Git::Object] git object for `origin/tracking_branch_name`
          def origin_tracking
            @git.object("origin/#{tracking_branch_name}")
          end

          # @return [::Git::Config] git config instance
          #
          # @see https://github.com/schacon/ruby-git
          def config
            @git.config
          end

          # @example tracking branch
          #   # from git config
          #   { "branch.spike/no-valid-master.merge" => "refs/heads/develop" }
          #   => "develop"
          #
          # @return [String] tracking branch name
          #
          # @see http://stackoverflow.com/questions/4950725/how-do-i-get-git-to-show-me-which-branches-are-tracking-what
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

          # @param commit [::Git::Object]
          #
          # @return [Boolean] true if commit is a merge commit
          def merge_commit?(commit)
            commit.parents.count == 2
          end

          # @return [String] push endpoint (defaults to: 'github.com')
          def push_endpoint
            (env_push_endpoint || 'github.com').chomp('/')
          end

          # @example via ssh
          #   'git@github.com:packsaddle/ruby-saddler-reporter-support-git.git'
          #   #=> 'github.com'
          #
          # @return [String, nil] push endpoint from env
          def env_push_endpoint
            ENV['PUSH_ENDPOINT'] if ENV['PUSH_ENDPOINT'] && !ENV['PUSH_ENDPOINT'].empty?
          end

          # @return [String, nil] current branch name from env
          def env_current_branch
            env_branch = EnvBranch.new do
              if ENV['CURRENT_BRANCH'] &&
                 !ENV['CURRENT_BRANCH'].empty?
                ENV['CURRENT_BRANCH']
              end
            end
            env_branch.branch_name
          end
        end
      end
    end
  end
end
