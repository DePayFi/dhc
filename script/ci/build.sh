#!/bin/bash -e

# custom vars
# RUBY = ruby-1.9.3-p125
# GEMSET = location-app-${GitHub pull request id|branch name}
# standard vars

if [ -z "$SKIP_RVM" ]; then
  [[ -s "/usr/local/rvm/scripts/rvm" ]] && . "/usr/local/rvm/scripts/rvm"
  RUBY=${RUBY:-ruby-2.1.2}
  GEMSET=${GEMSET:-DHC}
  rvm use ${RUBY}@${GEMSET} --create
  gem install bundler --no-rdoc --no-ri
fi

bundle install --local --quiet || bundle install --quiet
RAILS_ENV=test bundle exec rspec
bundle exec rspec non_rails_spec
rvm --force gemset delete ${RUBY}@${GEMSET}
