# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::Find, type: :operation do
  describe ".result" do
    context "when the medical shift exists" do
      it "is successful" do
        medical_shift = create(:medical_shift)

        result = described_class.result(id: medical_shift.id.to_s)

        expect(result).to be_success
      end

      it "returns the medical shift" do
        medical_shift = create(:medical_shift)

        result = described_class.result(id: medical_shift.id.to_s)

        expect(result.medical_shift).to eq(medical_shift)
      end
    end

    context "when the medical shift with given id does not exist" do
      it "raises ActiveRecord::RecordNotFound error" do
        expect do
          described_class.result(id: "non-existing-id")
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
