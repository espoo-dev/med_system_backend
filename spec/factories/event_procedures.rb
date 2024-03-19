# frozen_string_literal: true

FactoryBot.define do
  factory :event_procedure do
    health_insurance
    hospital
    patient
    procedure
    user

    patient_service_number { "202312150001" }
    date { "2023-12-15 16:02:00" }
    urgency { false }
    payd { false }
    room_type { EventProcedures::RoomTypes::WARD }
    total_amount_cents { procedure.amount_cents }
    payment { EventProcedures::Payments::HEALTH_INSURANCE }

    traits_for_enum(:room_type, EventProcedures::RoomTypes.list)
    traits_for_enum(:payment, EventProcedures::Payments.list)

    transient do
      patient_attributes { nil }
    end

    after(:build) do |event_procedure, evaluator|
      event_procedure.patient = build(:patient, evaluator.patient_attributes) if evaluator.patient_attributes
    end
  end
end
