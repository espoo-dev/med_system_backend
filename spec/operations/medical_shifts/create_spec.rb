# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::Create, type: :operation do
  describe ".result" do
    context "with valid attributes" do
      it "is successful" do
        attributes = {
          hospital_id: create(:hospital).id,
          workload: MedicalShifts::Workloads::SIX,
          date: "2024-01-29 10:51:23",
          amount_cents: 1,
          was_paid: false
        }

        result = described_class.result(attributes: attributes)

        expect(result.success?).to be true
      end

      it "creates a new medical shift" do
        attributes = {
          hospital_id: create(:hospital).id,
          workload: MedicalShifts::Workloads::SIX,
          date: "2024-01-29 10:51:23",
          amount_cents: 1,
          was_paid: false
        }

        result = described_class.result(attributes: attributes)

        expect(result.medical_shift).to be_persisted
      end
    end

    context "with invalid attributes" do
      it "fails" do
        attributes = { amount_cents: 1, was_paid: false }

        result = described_class.result(attributes: attributes)

        expect(result).to be_failure
      end

      it "does not create a new medical shift" do
        attributes = { amount_cents: 1, was_paid: false }

        result = described_class.result(attributes: attributes)

        expect(result.medical_shift).not_to be_persisted
        expect(result.medical_shift).not_to be_valid
      end

      it "returns an error" do
        attributes = { amount_cents: 1, was_paid: false }

        result = described_class.result(attributes: attributes)

        expect(result.error).to eq(:invalid_record)
        expect(result.medical_shift.errors.full_messages).to eq(
          [
            "Hospital must exist",
            "Workload can't be blank",
            "Date can't be blank"
          ]
        )
      end
    end
  end
end
