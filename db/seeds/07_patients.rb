# frozen_string_literal: true

$stdout.puts "6. Creating Patient..."

user = User.last
patient = Patient.create!(
  name: "Paciente Usuario 1",
  user_id: user.id
)
$stdout.puts "Created Patient: #{patient.name}"
