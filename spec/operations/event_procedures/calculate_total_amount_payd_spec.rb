# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::CalculateTotalAmountPayd, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.call

      expect(result.success?).to be true
    end

    it "returns payd amount cents" do
      _payd_amount_cents = create_list(
        :event_procedure, 3,
        procedure: create(:procedure, amount_cents: 5000),
        payd_at: Time.zone.now
      )
      _unpayd_event_procedure = create(
        :event_procedure,
        procedure: create(:procedure, amount_cents: 2000),
        payd_at: nil
      )

      payd = described_class.call.payd

      expect(payd).to eq "R$150.00"
    end
  end
end
