# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::ByMonthQuery do
  it "returns the medical shifts for the given month" do
    february_medical_shift = create(:medical_shift, date: "2023-02-15")
    _september_medical_shift = create(:medical_shift, date: "2023-09-26")

    by_month_query = described_class.call(month: "2")

    expect(by_month_query).to contain_exactly(february_medical_shift)
  end
end
