# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.8"

# Active Model Serializer [https://github.com/rails-api/active_model_serializers]
gem "active_model_serializers", "0.10.14"
# A Rails plugin to add soft delete. [https://github.com/ActsAsParanoid/acts_as_paranoid]
gem "acts_as_paranoid", "0.10.0"
# A Rails engine that helps you put together a super-flexible admin dashboard.
gem "administrate", "0.20.1"
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "1.18.3", require: false

# Rack middleware for blocking & throttling 
gem 'rack-attack'

# Use Sass to process CSS
# gem "sassc-rails"
# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Devise is a flexible authentication solution for Rails based on Warden [https://github.com/heartcombo/devise]
gem "devise", "4.9.4"
# devise-api authenticate API requests [https://github.com/nejdetkadir/devise-api]
gem "devise-api", github: "nejdetkadir/devise-api", branch: "main"
# Add devise-i18n for automatic translation of Devise views and messages
gem "devise-i18n", "~> 1.10"
# Enumerations for Ruby with some magic powers!
gem "enumerate_it", "4.0.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails", "2.0.1"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder", "2.11.5"
# A Scope & Engine based, clean, powerful, customizable and sophisticated paginator for Ruby webapps
gem "kaminari", "1.2.2"
# A Ruby Library for dealing with money and currency conversion.
gem "money", "6.16.0"

gem "multi_json", "1.15.0"
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
gem "packwerk", "3.1.0"
# Track changes to your models, for auditing or versioning.
gem "paper_trail", "15.1.0"
# This library provides a number of PDF::Reader based tools for use in testing PDF output.
gem "pdf-inspector", "1.3.0"
# Use pg as the database for Active Record
gem "pg", "1.5.4"
# Prawn is a pure Ruby PDF generation library [https://github.com/cortiz/prawn-rails]
gem "prawn-rails", "1.6.0"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "6.4.2"
# Minimal authorization through OO design and pure Ruby classes
gem "pundit", "2.3.2"
# Rack::Cors provides support for Cross-Origin Resource Sharing (CORS) for Rack compatible web applications [https://github.com/cyu/rack-cors]
gem "rack-cors", "2.0.2"
# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "7.1.3.4"
# Use Redis adapter to run Action Cable in production
gem "redis", "5.2.0"
# Sentry SDK for Rails
gem "sentry-rails", "5.17.3"
# Sentry SDK for Ruby
gem "sentry-ruby", "5.17.3"
# This Ruby gem lets you move your application logic into small composable service objects. [https://github.com/sunny/actor]
gem "service_actor", "3.7.0"
# Simple, efficient background processing for Ruby [https://github.com/sidekiq/sidekiq]
gem "sidekiq", "7.2.4"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails", "3.5.1"
# A sampling call-stack profiler for ruby 2.2+
gem "stackprof", "0.2.26"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails", "1.3.3"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails", "2.0.5"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem "debug", "1.9.2", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails", "3.1.2"
  gem "factory_bot_rails", "6.4.3"
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "pry", "0.14.2"
end

group :development do
  # To ensure code consistency [https://docs.rubocop.org]
  gem "rubocop", "1.56.2"
  gem "rubocop-factory_bot", "!= 2.26.0", require: false
  gem "rubocop-performance", "1.19.0"
  gem "rubocop-rails", "2.20.2"
  gem "rubocop-rspec", "2.23.2"
  gem "rubocop-rspec_rails", "!= 2.29.0", require: false
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console", "4.2.1"

  gem "brakeman", "6.1.2"

  # Preview mail in the browser instead of sending.
  gem "letter_opener", "1.10.0"
  gem "reek", "6.3.0"
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem "spring", "4.2.1"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara", "3.40.0"
  gem "pundit-matchers", "~> 4.0"
  gem "rspec-rails", "6.0.3"
  gem "rspec-sidekiq", "4.0.2"
  gem "selenium-webdriver", "4.12.0"
  gem "shoulda-matchers", "5.3.0"
  gem "simplecov", "0.22.0", require: false
  gem "spring-commands-rspec", "1.0.4"
end
