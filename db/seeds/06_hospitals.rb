# frozen_string_literal: true

$stdout.puts "5. Creating Hospital..."

hospital = Hospital.create!(
  name: "Hospital A",
  address: "A St."
)
$stdout.puts "Created Hospital: #{hospital.name}"
