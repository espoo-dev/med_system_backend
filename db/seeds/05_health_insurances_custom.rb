# frozen_string_literal: true

$stdout.puts "7. Creating custom Health Insurance..."

user = User.last
health_insurance = HealthInsurance.create!(
  name: "Plano de saude CUSTOM",
  custom: true,
  user_id: user.id
)
$stdout.puts "Created custom Health Insurance: #{health_insurance.name}"
