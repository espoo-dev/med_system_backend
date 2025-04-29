# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load dotenv only in development or test environment
Dotenv::Rails.load if %w[development test].include? ENV["RAILS_ENV"]

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # translate to PT-br
    config.i18n.available_locales = %w[pt-BR en]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.generators do |generator|
      generator.test_framework :rspec
    end

    config.active_job.queue_adapter = :sidekiq

    config.autoload_paths += %W[#{config.root}/lib #{config.root}/packs/oauth/app #{config.root}/packs/demo_pack/app]
  end
end
