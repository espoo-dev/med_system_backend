# frozen_string_literal: true

FactoryBot.define do
  factory :medical_shift do
    hospital
    user

    workload { MedicalShifts::Workloads::SIX }
    date { "2024-01-29 10:51:23" }
    amount_cents { 1 }
    was_paid { false }

    traits_for_enum(:workload, MedicalShifts::Workloads.list)
  end
end
