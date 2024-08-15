# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::ByHospitalQuery do
  it "returns the medical shifts for the given hospital_id" do
    hospital = create(:hospital)
    hospital_medical_shift = create(:medical_shift, hospital_name: hospital.name)
    _other_hospital_medical_shift = create(:medical_shift)

    by_hospital_query = described_class.call(hospital_name: hospital.name)

    expect(by_hospital_query).to contain_exactly(hospital_medical_shift)
  end
end
