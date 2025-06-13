# frozen_string_literal: true

require 'simplecov'

# Certifique-se de que o Rails está carregado antes de iniciar o SimpleCov
if defined?(Rails)
  Rails.application.eager_load!
end

SimpleCov.start do
  add_group "Controllers", "app/controllers"
  add_group "Jobs", "app/jobs"
  add_group "Lib", "app/lib"
  add_group "Models", "app/models"
  add_group "Mailers", "app/mailers"

  add_filter "config"
  add_filter %r{^/spec/}
  add_filter "app/channels"
  minimum_coverage 100
end

SimpleCov.at_exit do
  SimpleCov.result.format!
  exit(1) if SimpleCov.result.covered_percent < 100
end
