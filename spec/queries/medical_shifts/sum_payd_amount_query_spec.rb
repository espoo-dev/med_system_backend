# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::SumPaydAmountQuery do
  it "returns the sum of amount_cents" do
    _payd_medical_shift = create(:medical_shift, amount_cents: 2000, was_paid: true)
    _unpaid_medical_shift = create(:medical_shift, amount_cents: 1500, was_paid: false)

    sum_total_amount_query = described_class.call

    expect(sum_total_amount_query).to eq(2000)
  end
end
