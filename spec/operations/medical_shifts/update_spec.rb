# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::Update, type: :operation do
  describe ".result" do
    context "with valid attributes" do
      it "is successful" do
        medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX)
        new_attributes = { workload: MedicalShifts::Workloads::TWELVE }

        result = described_class.result(id: medical_shift.id.to_s, attributes: new_attributes)

        expect(result).to be_success
      end

      it "updates the medical shift" do
        medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX)
        new_attributes = { workload: MedicalShifts::Workloads::TWELVE }

        described_class.result(id: medical_shift.id.to_s, attributes: new_attributes)

        expect(medical_shift.reload.workload).to eq("twelve")
      end
    end

    context "with invalid attributes" do
      it "is failure" do
        medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX)

        result = described_class.result(id: medical_shift.id.to_s, attributes: { workload: nil })

        expect(result).to be_failure
        expect(result.medical_shift).not_to be_valid
      end

      it "returns error" do
        medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX)

        result = described_class.result(id: medical_shift.id.to_s, attributes: { workload: nil, date: nil })

        expect(result.error).to eq(:invalid_record)
        expect(result.medical_shift.errors.full_messages).to eq(["Workload can't be blank", "Date can't be blank"])
      end
    end
  end
end
