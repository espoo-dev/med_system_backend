# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::CalculateTotalAmountUnpayd, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.call

      expect(result.success?).to be true
    end

    it "returns unpayd amount cents" do
      create_list(:event_procedure, 3, procedure: create(:procedure, amount_cents: 1000))
      _unpayd_event_procedure = create(
        :event_procedure, procedure: create(:procedure, amount_cents: 2000),
        payd_at: nil
      )

      unpayd = described_class.call.unpayd

      expect(unpayd).to eq "R$20.00"
    end
  end
end
