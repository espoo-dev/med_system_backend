# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Active Model Serializer [https://github.com/rails-api/active_model_serializers]
gem "active_model_serializers"
# A Rails plugin to add soft delete. [https://github.com/ActsAsParanoid/acts_as_paranoid]
gem "acts_as_paranoid", "0.10.0"
# A Rails engine that helps you put together a super-flexible admin dashboard.
gem "administrate"
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
# Elasticsearch with chewy [https://github.com/toptal/chewy]
gem "chewy"

# Use Sass to process CSS
# gem "sassc-rails"
# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Devise is a flexible authentication solution for Rails based on Warden [https://github.com/heartcombo/devise]
gem "devise", "~> 4.9"
# devise-api authenticate API requests [https://github.com/nejdetkadir/devise-api]
gem "devise-api", github: "nejdetkadir/devise-api", branch: "main"
# Enumerations for Ruby with some magic powers!
gem "enumerate_it", "3.2.4"
# Ruby implementation of GraphQL [https://github.com/rmosolgo/graphql-ruby]
gem "graphql"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# A Scope & Engine based, clean, powerful, customizable and sophisticated paginator for Ruby webapps
gem "kaminari"
# A Ruby Library for dealing with money and currency conversion.
gem "money", "6.16.0"
# Infinite tracing for New Relic
# gem "newrelic-infinite_tracing", "9.9.0"
# Monitoring service New Relic
# gem "newrelic_rpm", "9.9.0"
# GitHub strategy for OmniAuth
gem "omniauth-github"
# Provides CSRF protection on OmniAuth request endpoint on Rails application.
gem "omniauth-rails_csrf_protection"
# GitHub strategy for Strava
gem "omniauth-strava"
# Packages sturcture support
gem "packwerk"
# Track changes to your models, for auditing or versioning.
gem "paper_trail"
# Use pg as the database for Active Record
gem "pg"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"
# Minimal authorization through OO design and pure Ruby classes
gem "pundit"
# Rack::Cors provides support for Cross-Origin Resource Sharing (CORS) for Rack compatible web applications [https://github.com/cyu/rack-cors]
gem "rack-cors"
# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8"
# Use Redis adapter to run Action Cable in production
gem "redis"
# Swagger to Rails-based API's [https://github.com/rswag/rswag]
gem "rswag"
# Sentry SDK for Rails
gem "sentry-rails"
# Sentry SDK for Ruby
gem "sentry-ruby"
# This Ruby gem lets you move your application logic into small composable service objects. [https://github.com/sunny/actor]
gem "service_actor", "~> 3.7"
# Simple, efficient background processing for Ruby [https://github.com/sidekiq/sidekiq]
gem "sidekiq"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# A sampling call-stack profiler for ruby 2.2+
gem "stackprof"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "bullet"

  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "graphiql-rails"
  gem "pry", "~> 0.14.2"
end

group :development do
  # To ensure code consistency [https://docs.rubocop.org]
  gem "rubocop", "1.56.2"
  gem "rubocop-graphql", "~> 1.4"
  gem "rubocop-performance", "1.19.0"
  gem "rubocop-rails", "2.20.2"
  gem "rubocop-rspec", "2.23.2"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "brakeman"
  gem "reek"
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "rspec-rails", "~> 6.0.0"
  gem "rspec-sidekiq"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 5.0"
  gem "simplecov", require: false
  gem "spring-commands-rspec"
end
