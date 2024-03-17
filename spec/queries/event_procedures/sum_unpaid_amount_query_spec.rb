# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::SumUnpaidAmountQuery do
  it "returns the sum unpaid of total_amount_cents" do
    user = create(:user)
    procedure_1000 = create(:procedure, amount_cents: 1000)
    procedure_1500 = create(:procedure, amount_cents: 1500)

    _event_procedure = create(:event_procedure, procedure: procedure_1000, payd_at: Time.zone.today, user: user)
    _payd_event_procedure = create(:event_procedure, procedure: procedure_1000, payd_at: Time.zone.today, user: user)
    _unpaid_event_procedure = create(:event_procedure, procedure: procedure_1500, payd_at: nil, user: user)

    sum_unpaid_amount_query = described_class.call(user_id: user.id)

    expect(sum_unpaid_amount_query).to eq(1500)
  end

  it "returns the sum unpayd of total_amount_cents for a specific month" do
    user = create(:user)
    procedure_1000 = create(:procedure, amount_cents: 1000)
    procedure_2000 = create(:procedure, amount_cents: 2000)

    _event_procedure_jan = create(
      :event_procedure, procedure: procedure_1000,
      date: "31/01/2023",
      payd_at: nil,
      user: user
    )
    _event_procedure_feb = create(
      :event_procedure, procedure: procedure_2000,
      date: "25/02/2023",
      payd_at: nil,
      user: user
    )

    sum_unpaid_amount_query = described_class.call(user_id: user.id, month: "1")

    expect(sum_unpaid_amount_query).to eq(1000)
  end
end
