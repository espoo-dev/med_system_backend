# frozen_string_literal: true

FactoryBot.define do
  factory :cbhpm_procedure do
    cbhpm
    procedure

    port { "1A" }
    anesthetic_port { "1" }
  end
end
