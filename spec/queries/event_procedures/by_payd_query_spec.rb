# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::ByPaydQuery do
  it "returns the medical shifts for the given was_paid" do
    paid_event_procedure = create(:event_procedure, payd_at: "23-09-2020")
    _unpaid_event_procedure = create(:event_procedure, payd_at: nil)

    by_payd_query = described_class.call(payd: "true")

    expect(by_payd_query).to contain_exactly(paid_event_procedure)
  end
end
