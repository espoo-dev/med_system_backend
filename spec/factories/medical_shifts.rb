# frozen_string_literal: true

FactoryBot.define do
  factory :medical_shift do
    user

    hospital_name { "Hospital Test" }
    workload { MedicalShifts::Workloads::SIX }
    start_date { "2024-01-29" }
    start_hour { "10:51:23" }
    amount_cents { 1 }
    paid { false }
    color { "#ffffff" }

    traits_for_enum(:workload, MedicalShifts::Workloads.list)

    trait :with_recurrence do
      medical_shift_recurrence
    end
  end
end
