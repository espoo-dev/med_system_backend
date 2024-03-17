# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::TotalAmountCents, type: :operation do
  describe ".result" do
    it "is successful" do
      user = create(:user)

      expect(described_class.result(user_id: user.id, month: nil)).to be_success
    end

    it "returns the amount_cents total, paid and unpaid of event_procedures" do
      user = create(:user)
      _payd_amount_cents = create_list(
        :event_procedure, 3,
        procedure: create(:procedure, amount_cents: 5000),
        user: user,
        payd_at: Time.zone.now
      )
      _unpayd_event_procedure = create(
        :event_procedure,
        procedure: create(:procedure, amount_cents: 2000),
        user: user,
        payd_at: nil
      )
      total_amount_cents = described_class.call(user_id: user.id, month: nil)

      expect(total_amount_cents.total).to eq("R$170.00")
      expect(total_amount_cents.payd).to eq("R$150.00")
      expect(total_amount_cents.unpaid).to eq("R$20.00")
    end

    it "calculates the total, payd, and unpaid amounts for a specific month" do
      user = create(:user)
      procedure_1000 = create(:procedure, amount_cents: 1000)
      procedure_2000 = create(:procedure, amount_cents: 2000)

      _event_procedure_jan = create(
        :event_procedure, procedure: procedure_1000,
        date: "31/01/2023",
        payd_at: "26/03/2023",
        user: user
      )
      _payd_event_procedure_feb = create(
        :event_procedure, procedure: procedure_2000,
        date: "25/02/2023",
        payd_at: "26/03/2023",
        user: user
      )
      _unpayd_event_procedure_feb = create(
        :event_procedure, procedure: procedure_1000,
        date: "25/02/2023",
        payd_at: nil,
        user: user
      )

      total_amount_cents = described_class.call(user_id: user.id, month: "2")

      expect(total_amount_cents.total).to eq("R$30.00")
      expect(total_amount_cents.payd).to eq("R$20.00")
      expect(total_amount_cents.unpaid).to eq("R$10.00")
    end
  end
end
