# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::ByPaydQuery do
  it "returns the medical shifts for the given was_paid" do
    payd_medical_shift = create(:medical_shift, payd: true)
    _unpayd_medical_shift = create(:medical_shift, payd: false)

    by_payd_query = described_class.call(payd: "true")

    expect(by_payd_query).to contain_exactly(payd_medical_shift)
  end
end
