# frozen_string_literal: true

$stdout.puts "Creating EventProcedures..."

user = User.last
patient = Patient.last
hospital = Hospital.last
procedure_default = Procedure.first
procedure_custom = Procedure.last
health_insurance_default = HealthInsurance.first
health_insurance_custom = HealthInsurance.last
cbhpm = Cbhpm.last

event_procedure_default = EventProcedure.create!(
  procedure_id: procedure_default.id,
  patient_id: patient.id,
  hospital_id: hospital.id,
  health_insurance_id: health_insurance_default.id,
  patient_service_number: "PSN12345",
  date: DateTime.current + 1.day,
  urgency: false,
  room_type: :ward,
  user_id: user.id,
  payd: false,
  payment: :health_insurance,
  cbhpm_id: cbhpm.id
)

total_amount_cents_procedure_default = EventProcedures::BuildTotalAmountCents.result(event_procedure: event_procedure_default)
event_procedure_default.update(total_amount_cents: total_amount_cents_procedure_default)

EventProcedure.create!(
  procedure_id: procedure_custom.id,
  patient_id: patient.id,
  hospital_id: hospital.id,
  health_insurance_id: health_insurance_custom.id,
  patient_service_number: "PSN67890",
  date: DateTime.current + 2.days,
  urgency: true,
  room_type: :apartment,
  total_amount_cents: 15_000,
  user_id: user.id,
  payd: false,
  payment: :others,
  cbhpm_id: cbhpm.id
)

$stdout.puts "Created EventProcedures for user"
