# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::TotalAmountCents, type: :operation do
  describe ".call" do
    it "returns the total, payd and unpaid amount_cents of money" do
      user = create(:user)
      _medical_shift = create(:medical_shift, amount_cents: 1000, was_paid: true, user: user)
      _payd_medical_shift = create(:medical_shift, amount_cents: 2000, was_paid: true, user: user)
      _unpaid_medical_shift = create(:medical_shift, amount_cents: 1500, was_paid: false, user: user)

      result = described_class.call(user_id: user.id)

      expect(result.total).to eq("R$45.00")
      expect(result.payd).to eq("R$30.00")
      expect(result.unpaid).to eq("R$15.00")
    end
  end
end
