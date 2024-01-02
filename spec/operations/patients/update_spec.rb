# frozen_string_literal: true

require "rails_helper"

RSpec.describe Patients::Update, type: :operation do
  describe ".result" do
    context "with valid attributes" do
      let!(:patient) { create(:patient, name: "Old Name") }

      it "is successful" do
        valid_attributes = { name: "New Name" }
        result = described_class.result(id: patient.id.to_s, attributes: valid_attributes)

        expect(result).to be_success
      end

      it "updates the patient" do
        valid_attributes = { name: "New Name" }
        described_class.result(id: patient.id.to_s, attributes: valid_attributes)

        expect(patient.reload.name).to eq("New Name")
      end
    end

    context "with invalid attributes" do
      let!(:patient) { create(:patient, name: "Old Name") }

      it "is failure" do
        invalid_attributes = { name: "" }
        result = described_class.result(id: patient.id.to_s, attributes: invalid_attributes)

        expect(result).to be_failure
      end

      it "does not update the patient" do
        invalid_attributes = { name: nil }
        described_class.result(id: patient.id.to_s, attributes: invalid_attributes)

        expect(patient.reload.name).to eq("Old Name")
      end

      it "returns an error" do
        invalid_attributes = { name: nil }
        result = described_class.result(id: patient.id.to_s, attributes: invalid_attributes)

        expect(result.patient.errors.full_messages).to eq(["Name can't be blank"])
      end
    end
  end
end
