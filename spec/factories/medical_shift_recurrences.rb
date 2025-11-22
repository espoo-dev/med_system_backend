# frozen_string_literal: true

FactoryBot.define do
  factory :medical_shift_recurrence do
    user

    frequency { "weekly" }
    day_of_week { 3 } # quarta-feira
    start_date { Date.tomorrow }
    workload { "12h" }
    start_hour { "19:00" }
    hospital_name { "Hospital Teste" }
    amount_cents { 120_000 }

    trait :weekly do
      frequency { "weekly" }
      day_of_week { 1 } # segunda
      day_of_month { nil }
    end

    trait :biweekly do
      frequency { "biweekly" }
      day_of_week { 5 } # sexta
      day_of_month { nil }
    end

    trait :monthly_fixed_day do
      frequency { "monthly_fixed_day" }
      day_of_week { nil }
      day_of_month { 15 }
    end

    trait :with_end_date do
      end_date { 6.months.from_now.to_date }
    end

    trait :deleted do
      deleted_at { Time.current }
    end
  end
end
