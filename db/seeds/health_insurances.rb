# frozen_string_literal: true

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
