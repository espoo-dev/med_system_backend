# frozen_string_literal: true

FactoryBot.define do
  factory :procedure do
    name { "Procedure name" }
    sequence(:code) { |n| "code#{n}" }
    amount_cents { 1 }
    description { "Procedure description" }
  end
end
