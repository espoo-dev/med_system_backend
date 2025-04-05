# frozen_string_literal: true

Rails.logger.debug "4. Creating default Health Insurances..."

health_insurance_data = [
  "São Camilo",
  "ISSEC",
  "UNIMED",
  "AMIL",
  "BRADESCO",
  "FUNCEF Caixa",
  "SUL AMÉRICA",
  "CASSI",
  "HMSM"
]

health_insurance_data.each do |name|
  HealthInsurance.create!(name: name)
end

Rails.logger.debug { "Created #{health_insurance_data.count} default Health Insurances..." }
