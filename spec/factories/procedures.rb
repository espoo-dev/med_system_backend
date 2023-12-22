# frozen_string_literal: true

FactoryBot.define do
  factory :procedure do
    name { "Procedure name" }
    code { "03.02.04.01-5" }
    amount_cents { 1 }
    description { "Procedure description" }
  end
end
