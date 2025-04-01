# frozen_string_literal: true

$stdout.puts "9. Creating Medical Shifts..."

date = Date.yesterday
user = User.last
hospital = Hospital.last
MedicalShift.create!(
  user_id: user.id,
  workload: :twelve,
  start_date: date,
  start_hour: Time.new(date.year, date.month, date.day, 8, 0, 0),
  amount_cents: 1_511_80,
  payd: false,
  hospital_name: hospital.name
)

MedicalShift.create!(
  user_id: user.id,
  workload: :six,
  start_date: date,
  start_hour: Time.new(date.year, date.month, date.day, 14, 0, 0),
  amount_cents: 755_90,
  payd: true,
  hospital_name: hospital.name
)

$stdout.puts "Created Medical Shifts for user on #{date}"
