# frozen_string_literal: true

FactoryBot.define do
  factory :patient do
    sequence(:name) { |n| "patient #{n}" }
    user
  end
end
