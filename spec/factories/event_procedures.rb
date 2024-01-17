# frozen_string_literal: true

FactoryBot.define do
  factory :event_procedure do
    health_insurance
    hospital
    patient
    procedure

    patient_service_number { "202312150001" }
    date { "2023-12-15 16:02:00" }
    urgency { false }
    payd_at { "2023-12-15 16:02:00" }
    room_type { EventProcedures::RoomTypes::WARD }
    total_amount_cents { procedure.amount_cents }

    traits_for_enum(:room_type, EventProcedures::RoomTypes.list)
  end
end
