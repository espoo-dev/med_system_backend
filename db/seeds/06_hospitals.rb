# frozen_string_literal: true

Rails.logger.debug "5. Creating Hospital..."

hospital = Hospital.create!(
  name: "Hospital A",
  address: "A St."
)
Rails.logger.debug { "Created Hospital: #{hospital.name}" }
