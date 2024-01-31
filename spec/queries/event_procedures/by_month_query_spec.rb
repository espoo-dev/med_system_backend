# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::ByMonthQuery do
  it "returns the event_procedures for the given month" do
    september_event_procedure = create(:event_procedure, date: "2020-09-01")
    _february_event_procedure = create(:event_procedure, date: "2020-02-01")

    by_month_query = described_class.call(month: "9")

    expect(by_month_query).to contain_exactly(september_event_procedure)
  end
end
