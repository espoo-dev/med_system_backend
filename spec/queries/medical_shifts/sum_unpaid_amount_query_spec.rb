# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::SumUnpaidAmountQuery do
  it "returns the sum of amount_cents" do
    user = create(:user)
    _payd_medical_shift = create(:medical_shift, amount_cents: 2000, payd: true, user:, start_date: "25/02/2023")
    _unpaid_medical_shift = create(:medical_shift, amount_cents: 1500, payd: false, user:, start_date: "25/02/2023" )
    _unpayd_medical_shift2 = create(:medical_shift, amount_cents: 2000, payd: false, user:, start_date: "25/03/2023")

    amount_by_month = described_class.call(user_id: user.id, month: 2)
    amount_without_month = described_class.call(user_id: user.id,)

    expect(amount_by_month).to eq(1500)
    expect(amount_without_month).to eq(3500)
  end
end
