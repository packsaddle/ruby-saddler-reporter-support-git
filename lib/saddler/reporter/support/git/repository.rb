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
            regex_slug = %r{[[:alnum:]_\-\.]*/[[:alnum:]_\-\.]*}
            regex = %r{.*?#{Regexp.quote(push_endpoint)}/(?<slug>#{regex_slug})}
            remote_urls.map do |url|
              match = regex.match(strip_git_extension(url))
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

          def strip_git_extension(name)
            match = /\A(?<identity>.*?)(?:\.git)?\z/.match(name)
            match[:identity] if match
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
