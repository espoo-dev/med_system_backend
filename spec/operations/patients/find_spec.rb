# frozen_string_literal: true

require "rails_helper"

RSpec.describe Patients::Find, type: :operation do
  describe ".result" do
    context "when patient with given id exists" do
      it "is successful" do
        patient = create(:patient)

        result = described_class.result(id: patient.id.to_s)

        expect(result).to be_success
      end

      it "returns found patient" do
        patient = create(:patient)

        result = described_class.result(id: patient.id.to_s)

        expect(result.patient).to eq(patient)
      end
    end

    context "when patient with given id does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect do
          described_class.result(id: "invalid_id")
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when using a scope" do
      let(:user) { create(:user) }
      let(:patient) { create(:patient, user: user) }
      let(:other_patient) { create(:patient) }

      it "returns found patient when it exists in scope" do
        result = described_class.result(
          id: patient.id.to_s,
          scope: Patient.where(user: user)
        )

        expect(result.patient).to eq(patient)
      end

      it "raises ActiveRecord::RecordNotFound when record exists but not in scope" do
        expect do
          described_class.result(
            id: other_patient.id.to_s,
            scope: Patient.where(user: user)
          )
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
