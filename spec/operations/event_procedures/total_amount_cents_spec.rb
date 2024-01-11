# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::TotalAmountCents, type: :operation do
  describe ".result" do
    it "is successful" do
      expect(described_class.result).to be_success
    end

    it "returns the amount_cents total, paid and unpaid of event_procedures" do
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
      result = described_class.result

      expect(result.total).to eq("R$170.00")
      expect(result.payd).to eq("R$150.00")
      expect(result.unpayd).to eq("R$20.00")
    end
  end
end
