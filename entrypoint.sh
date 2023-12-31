#!/bin/sh
cd /app
sleep 5 # just to make sure postgres is up
echo "run db:reset"
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bin/rails db:reset db:create db:migrate db:seed
echo "run Puma"
bin/bundle exec puma -C config/puma.rb
