# frozen_string_literal: true

# Not proud of, but we are using this as a place to run scripts,
# since we can't run rake tasks or access console on render free version

# set the field payd to event_procedures
event_procedures = EventProcedure.where.not(payd_at: nil)
event_procedures.each { _1.update(payd: true) }

# Rails.logger.debug "Seeding default data..."
# Dir[Rails.root.join("db/seeds/*.rb")].each do |seed|
#   load seed
# end

# Rails.logger.debug { "Seeding #{Rails.env} data..." }
# Dir[Rails.root.join("db/seeds", Rails.env, "*.rb")].each do |seed|
#   load seed
# end
