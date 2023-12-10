# frozen_string_literal: true

FactoryBot.define do
  factory :hospital do
    sequence(:name) { |n| "hospital #{n}" }
    sequence(:address) { |n| "address #{n}" }
  end
end
