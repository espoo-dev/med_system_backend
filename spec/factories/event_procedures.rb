# frozen_string_literal: true

FactoryBot.define do
  factory :event_procedure do
    cbhpm
    health_insurance
    hospital
    user
    procedure

    patient_service_number { "202312150001" }
    date { "2023-12-15 16:02:00" }
    urgency { false }
    paid { false }
    room_type { EventProcedures::RoomTypes::WARD }
    total_amount_cents { procedure.amount_cents }
    payment { EventProcedures::Payments::HEALTH_INSURANCE }

    traits_for_enum(:room_type, EventProcedures::RoomTypes.list)
    traits_for_enum(:payment, EventProcedures::Payments.list)

    transient do
      health_insurance_attributes { nil }
      patient_attributes { nil }
      procedure_attributes { nil }
    end

    after(:build) do |event_procedure, evaluator|
      event_procedure.user ||= build(:user)
      event_procedure.patient ||= build(
        :patient,
        (evaluator.patient_attributes || {}).merge(user: event_procedure.user)
      )
      event_procedure.procedure = build(:procedure, evaluator.procedure_attributes) if evaluator.procedure_attributes

      if evaluator.health_insurance_attributes
        event_procedure.health_insurance = build(:health_insurance, evaluator.health_insurance_attributes)
      end
    end

    trait :with_port_values do
      after(:create) do |ep|
        create_list(:port_value, 2, cbhpm: ep.cbhpm)
      end
    end
  end
end
