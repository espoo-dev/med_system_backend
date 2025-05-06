# frozen_string_literal: true

# Not proud of, but we are using this as a place to run scripts,
# since we can't run rake tasks or access console on render free version

if Rails.env.development?
  Rails.logger.debug "Seeding data..."
  Rails.root.glob("db/seeds/*.rb").each do |seed|
    load seed
  end
else
  Rails.logger.debug { "Skipping seed data loading in #{Rails.env} environment" }
end

# Rails.logger.debug { "Seeding #{Rails.env} data..." }
# Dir[Rails.root.join("db/seeds", Rails.env, "*.rb")].each do |seed|
#   load seed
# end
