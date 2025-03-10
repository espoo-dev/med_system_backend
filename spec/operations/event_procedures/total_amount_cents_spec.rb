# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::TotalAmountCents, type: :operation do
  describe ".result" do
    it "is successful" do
      user = create(:user)
      event_procedure = create(:event_procedure, user_id: user.id)
      expect(described_class.result(event_procedures: [event_procedure])).to be_success
    end

    it "returns the amount_cents total, paid and unpaid of event_procedures" do
      user = create(:user)
      procedure_5000 = create(:procedure, amount_cents: 5000)
      procedure_2000 = create(:procedure, amount_cents: 2000)
      payd_amount_cents = create_list(
        :event_procedure, 3,
        procedure: procedure_5000,
        user: user,
        payd: true
      )
      unpayd_event_procedure = create_list(
        :event_procedure, 2,
        procedure: procedure_2000,
        user: user,
        payd: false
      )
      event_procedures = payd_amount_cents + unpayd_event_procedure
      total_amount_cents = described_class.call(event_procedures: event_procedures)
      expect(total_amount_cents.total).to eq("R$190.00")
      expect(total_amount_cents.payd).to eq("R$150.00")
      expect(total_amount_cents.unpaid).to eq("R$40.00")
    end
  end
end
