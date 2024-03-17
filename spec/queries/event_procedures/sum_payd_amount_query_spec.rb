# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::SumPaydAmountQuery do
  it "returns the sum payd of total_amount_cents" do
    user = create(:user)
    procedure_1000 = create(:procedure, amount_cents: 1000)
    procedure_1500 = create(:procedure, amount_cents: 1500)

    _event_procedure = create(:event_procedure, procedure: procedure_1000, payd: true, user: user)
    _payd_event_procedure = create(:event_procedure, procedure: procedure_1000, payd: true, user: user)
    _unpaid_event_procedure = create(:event_procedure, procedure: procedure_1500, payd: false, user: user)

    sum_payd_amount_query = described_class.call(user_id: user.id)

    expect(sum_payd_amount_query).to eq(2000)
  end

  it "returns the sum payd of total_amount_cents for a specific month" do
    user = create(:user)
    procedure_1000 = create(:procedure, amount_cents: 1000)
    procedure_2000 = create(:procedure, amount_cents: 2000)

    _event_procedure_jan = create(
      :event_procedure, procedure: procedure_1000,
      date: "31/01/2023",
      payd: true,
      user: user
    )
    _event_procedure_feb = create(
      :event_procedure, procedure: procedure_2000,
      date: "25/02/2023",
      payd: true,
      user: user
    )

    sum_payd_amount_query = described_class.call(user_id: user.id, month: "2")

    expect(sum_payd_amount_query).to eq(2000)
  end
end
