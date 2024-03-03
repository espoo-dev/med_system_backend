# frozen_string_literal: true

require "rails_helper"

RSpec.describe Patients::FindOrCreate, type: :operation do
  describe ".result" do
    let(:user_id) { create(:user).id }

    context "when patient with given id exists" do
      it "is successful" do
        patient = create(:patient)
        params = { id: patient.id }

        result = described_class.result(params: params)

        expect(result).to be_success
      end

      it "returns found patient" do
        patient = create(:patient)
        params = { id: patient.id }

        result = described_class.result(params: params).patient

        expect(result).to eq(patient)
      end
    end

    context "when patient with given id does not exist" do
      it "is successful" do
        params = { id: nil, name: "John", user_id: }

        result = described_class.result(params: params)

        expect(result).to be_success
      end

      it "creates a patient" do
        params = { id: nil, name: "John", user_id: }

        result = described_class.result(params: params)

        expect(result.patient).to be_persisted
        expect(result.patient.name).to eq("John")
      end
    end

    context "when params are empty" do
      it "is failure" do
        params = { id: nil, name: "" }

        result = described_class.result(params: params)

        expect(result).to be_failure
      end

      it "returns errors" do
        params = { id: nil, name: nil, user_id: }

        result = described_class.result(params: params)

        expect(result.error).to eq(:invalid_record)
        expect(result.patient.errors.full_messages).to eq(["Name can't be blank"])
      end
    end
  end
end
