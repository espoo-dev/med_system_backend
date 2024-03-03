# frozen_string_literal: true

User.create(email: "admin@email.com", password: "password", admin: true)
User.create(email: "edimossilva@gmail.com", password: "edimossilva@gmail.com", admin: true)
User.create(email: "daniel@gmail.com", password: "daniel@gmail.com", admin: true)

procedure = Procedure.all
procedure.select { _1.id > 25 }.each(&:destroy)

health_insurance = HealthInsurance.all
health_insurance.select { _1.id > 9 }.each(&:destroy)

# Rails.logger.debug "Seeding default data..."
# Dir[Rails.root.join("db/seeds/*.rb")].each do |seed|
#   load seed
# end

# Rails.logger.debug { "Seeding #{Rails.env} data..." }
# Dir[Rails.root.join("db/seeds", Rails.env, "*.rb")].each do |seed|
#   load seed
# end
