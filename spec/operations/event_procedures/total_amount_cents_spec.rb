# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::TotalAmountCents, type: :operation do
  describe ".result" do
    it "is successful" do
      user = create(:user)
      event_procedure = create(:event_procedure, user_id: user.id)
      expect(described_class.result(event_procedures: [event_procedure])).to be_success
    end

    it "correctly calculates total, paid and unpaid amounts" do
      user = create(:user)
      procedure_5000 = create(:procedure, amount_cents: 5000, custom: true, user: user)
      procedure_2000 = create(:procedure, amount_cents: 2000, custom: true, user: user)
      paid_event_procedures = create_list(
        :event_procedure, 3,
        procedure: procedure_5000,
        user: user,
        payd: true,
        urgency: false
      )
      unpaid_event_procedures = create_list(
        :event_procedure, 2,
        procedure: procedure_2000,
        user: user,
        payd: false,
        urgency: false
      )

      event_procedures = paid_event_procedures + unpaid_event_procedures
      total_amount_cents = described_class.call(event_procedures: event_procedures)

      expect(total_amount_cents.total).to eq("R$190.00")
      expect(total_amount_cents.payd).to eq("R$150.00")
      expect(total_amount_cents.unpaid).to eq("R$40.00")
    end
  end
end
