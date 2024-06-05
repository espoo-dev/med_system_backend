# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::WithAssociationsQuery, type: :query do
  let(:procedure) { create(:procedure, name: "Procedure", amount_cents: 100, description: "Description") }
  let(:patient) { create(:patient, name: "Patient") }
  let(:hospital) { create(:hospital, name: "Hospital") }
  let(:health_insurance) { create(:health_insurance, name: "Health Insurance") }

  it "returns event procedures with associations" do # rubocop:disable RSpec/MultipleExpectations
    user = create(:user)
    _event_procedure = create(
      :event_procedure, procedure: procedure, patient: patient, hospital: hospital,
      health_insurance: health_insurance,
      user: user
    )

    result = described_class.call(relation: EventProcedure.where(user: user))

    expect(result.first.procedure_name).to eq("Procedure")
    expect(result.first.procedure_amount_cents).to eq(100)
    expect(result.first.procedure_description).to eq("Description")
    expect(result.first.patient_name).to eq("Patient")
    expect(result.first.hospital_name).to eq("Hospital")
    expect(result.first.health_insurance_name).to eq("Health Insurance")
  end
end
