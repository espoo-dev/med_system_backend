# frozen_string_literal: true

Rails.logger.debug "7. Creating custom Health Insurance..."

user = User.last
health_insurance = HealthInsurance.create!(
  name: "Plano de saude CUSTOM",
  custom: true,
  user_id: user.id
)
Rails.logger.debug { "Created custom Health Insurance: #{health_insurance.name}" }
