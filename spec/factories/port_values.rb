# frozen_string_literal: true

FactoryBot.define do
  factory :port_value do
    cbhpm

    port { "1A" }
    anesthetic_port { "1" }
    amount_cents { 1 }
  end
end
