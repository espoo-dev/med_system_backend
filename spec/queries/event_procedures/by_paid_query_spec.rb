# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::ByPaidQuery do
  it "returns the medical shifts for the given was_paid" do
    paid_event_procedure = create(:event_procedure, paid: true)
    _unpaid_event_procedure = create(:event_procedure, paid: false)

    by_paid_query = described_class.call(paid: "true")

    expect(by_paid_query).to contain_exactly(paid_event_procedure)
  end
end
