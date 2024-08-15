# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::SumPaydAmountQuery do
  it "returns the sum of amount_cents" do
    user = create(:user)
    _payd_medical_shift = create(:medical_shift, amount_cents: 2000, payd: true, user: user)
    _unpaid_medical_shift = create(:medical_shift, amount_cents: 1500, payd: false, user: user)

    sum_total_amount_query = described_class.call(user_id: user.id)

    expect(sum_total_amount_query).to eq(2000)
  end
end
