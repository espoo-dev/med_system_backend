# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::ByPaidQuery do
  it "returns the medical shifts for the given was_paid" do
    paid_medical_shift = create(:medical_shift, paid: true)
    _unpaid_medical_shift = create(:medical_shift, paid: false)

    by_paid_query = described_class.call(paid: "true")

    expect(by_paid_query).to contain_exactly(paid_medical_shift)
  end
end
