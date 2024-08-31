# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::Destroy, type: :operation do
  describe ".result" do
    subject(:result) { described_class.result(id: medical_shift.id.to_s) }

    context "when medical_shift can be destroyed" do
      let(:medical_shift) { create(:medical_shift) }

      before { medical_shift }

      it { expect(result).to be_success }
      it { expect { result }.to change(MedicalShift, :count).by(-1) }
    end

    context "when medical_shift cannot be destroyed" do
      let(:medical_shift) { create(:medical_shift) }

      before do
        allow(MedicalShift).to receive(:find).with(medical_shift.id.to_s).and_return(medical_shift)
        allow(medical_shift).to receive(:destroy).and_return(false)
      end

      it { expect(result).to be_failure }
      it { expect { result }.not_to change(MedicalShift, :count) }
      it { expect(result.error).to eq(:cannot_destroy) }
    end

    context "when event_procedure with given id doesn't exist" do
      subject(:result) { described_class.result(id: "nonexistent") }

      it { expect { result }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
