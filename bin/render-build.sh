#!/usr/bin/env bash
# Render build script: install gems, prepare DB, precompile assets
set -o errexit

# Install production gems
bundle install

# Prepare the database (run pending migrations + seed data)
bundle exec rails db:migrate
bundle exec rails db:seed

# Precompile assets
bundle exec rails assets:precompile