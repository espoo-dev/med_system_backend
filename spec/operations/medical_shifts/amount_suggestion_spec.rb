# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::AmountSuggestion, type: :operation do
  describe "#call" do
    context "when there are no amounts stored" do
      let(:user) { create(:user) }

      it "returns an empty list" do
        result = described_class.result(scope: MedicalShift.all)

        expect(result.amounts_cents).to be_empty
      end
    end

    context "when there are amounts stored" do
      let(:user) { create(:user) }
      let(:another_user) { create(:user) }

      before do
        create(:medical_shift, user:, amount_cents: 100_000)
        create(:medical_shift, user:, amount_cents: 100_000) # Duplicate amount
        create(:medical_shift, user:, amount_cents: 200_000)
        create(:medical_shift, user:, amount_cents: 300_000)
      end

      it "returns unique amounts" do
        result = described_class.result(scope: MedicalShift.all)

        expected_amounts = ["R$1.000,00", "R$2.000,00", "R$3.000,00"]
        expect(result.amounts_cents).to match_array(expected_amounts)
      end
    end
  end
end
