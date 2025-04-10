# frozen_string_literal: true

Rails.logger.debug "9. Creating Medical Shifts..."

date = Date.yesterday
user = User.last
hospital = Hospital.last
MedicalShift.create!(
  user_id: user.id,
  workload: :twelve,
  start_date: date,
  start_hour: Time.zone.local(date.year, date.month, date.day, 8, 0, 0),
  amount_cents: 1_511_80,
  paid: false,
  hospital_name: hospital.name
)

MedicalShift.create!(
  user_id: user.id,
  workload: :six,
  start_date: date,
  start_hour: Time.zone.local(date.year, date.month, date.day, 14, 0, 0),
  amount_cents: 755_90,
  paid: true,
  hospital_name: hospital.name
)

Rails.logger.debug { "Created Medical Shifts for user on #{date}" }
