# frozen_string_literal: true

FactoryBot.define do
  factory :health_insurance do
    sequence(:name) { |n| "health insurance #{n}" }
    custom { false }
  end
end
