# frozen_string_literal: true

require "rails_helper"

RSpec.describe Patients::Destroy, type: :operation do
  describe ".result" do
    context "when the patient can be destroyed" do
      let!(:patient) { create(:patient) }

      it "is successful" do
        expect(described_class.result(id: patient.id.to_s)).to be_success
      end

      it "destroys the patient" do
        expect { described_class.result(id: patient.id.to_s) }.to change(Patient, :count).by(-1)
      end
    end

    context "when the patient cannot be destroyed" do
      let!(:patient) { create(:patient) }

      it "is failure" do
        allow(Patient).to receive(:find).with(patient.id.to_s).and_return(patient)
        allow(patient).to receive(:destroy).and_return(false)

        expect(described_class.result(id: patient.id.to_s)).to be_failure
      end

      it "does not destroy the patient" do
        allow(Patient).to receive(:find).with(patient.id.to_s).and_return(patient)
        allow(patient).to receive(:destroy).and_return(false)

        expect { described_class.result(id: patient.id.to_s) }.not_to change(Patient, :count)
      end

      it "returns error :cannot_destroy" do
        allow(Patient).to receive(:find).with(patient.id.to_s).and_return(patient)
        allow(patient).to receive(:destroy).and_return(false)

        expect(described_class.result(id: patient.id.to_s).error).to eq(:cannot_destroy)
      end
    end

    context "when the patient with given id does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { described_class.result(id: "non-existent-id") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
