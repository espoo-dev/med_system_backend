# frozen_string_literal: true

Rails.logger.debug "6. Creating Patient..."

user = User.last
patient = Patient.create!(
  name: "Paciente Usuario 1",
  user_id: user.id
)
Rails.logger.debug { "Created Patient: #{patient.name}" }
