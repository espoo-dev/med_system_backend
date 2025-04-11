# frozen_string_literal: true

Rails.logger.debug "Creating EventProcedures..."

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
  urgency: true,
  room_type: :apartment,
  user_id: user.id,
  payd: true,
  payment: :health_insurance,
  cbhpm_id: cbhpm.id
)

event_procedure_default_updated = EventProcedures::BuildTotalAmountCents.result(
  event_procedure: event_procedure_default
)
event_procedure_default.update(total_amount_cents: event_procedure_default_updated.total_amount_cents)

custom_event_procedures_data_unpaid = [
  { psn: "PSN67890", date: DateTime.current - 2.days, amount: 15_00 },
  { psn: "PSN67891", date: DateTime.current - 3.days, amount: 20_00 },
  { psn: "PSN67892", date: DateTime.current - 4.days, amount: 80_00 },
  { psn: "PSN67893", date: DateTime.current - 5.days, amount: 25_00 },
  { psn: "PSN67894", date: DateTime.current - 6.days, amount: 20_00 },
  { psn: "PSN67895", date: DateTime.current - 7.days, amount: 30_00 },
  { psn: "PSN67896", date: DateTime.current - 8.days, amount: 40_00 }
]

custom_paid_event_procedures_data_paid = [
  { psn: "PSN67900", date: DateTime.current - 9.days, amount: 10_00 },
  { psn: "PSN67901", date: DateTime.current - 10.days, amount: 150_00 },
  { psn: "PSN67902", date: DateTime.current - 11.days, amount: 50_00 },
  { psn: "PSN67903", date: DateTime.current - 12.days, amount: 100_00 },
  { psn: "PSN67904", date: DateTime.current - 13.days, amount: 1_000_00 },
  { psn: "PSN67905", date: DateTime.current - 14.days, amount: 200_00 },
  { psn: "PSN67906", date: DateTime.current - 15.days, amount: 300_00 }
]

custom_event_procedures_data_unpaid.each do |data|
  EventProcedure.create!(
    procedure_id: procedure_custom.id,
    patient_id: patient.id,
    hospital_id: hospital.id,
    health_insurance_id: health_insurance_custom.id,
    patient_service_number: data[:psn],
    date: data[:date],
    urgency: false,
    room_type: :ward,
    total_amount_cents: data[:amount],
    user_id: user.id,
    payd: false,
    payment: :others,
    cbhpm_id: cbhpm.id
  )
end

custom_paid_event_procedures_data_paid.each do |data|
  EventProcedure.create!(
    procedure_id: procedure_custom.id,
    patient_id: patient.id,
    hospital_id: hospital.id,
    health_insurance_id: health_insurance_custom.id,
    patient_service_number: data[:psn],
    date: data[:date],
    urgency: false,
    room_type: :ward,
    total_amount_cents: data[:amount],
    user_id: user.id,
    payd: true,
    payment: :health_insurance,
    cbhpm_id: cbhpm.id
  )
end

Rails.logger.debug "Created EventProcedures for user"
