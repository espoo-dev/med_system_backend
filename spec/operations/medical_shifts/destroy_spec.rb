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
        medical_shift
        allow_any_instance_of(MedicalShift).to receive(:destroy).and_return(false) # rubocop:disable RSpec/AnyInstance
      end

      it { expect(result).to be_failure }
      it { expect { result }.not_to change(MedicalShift, :count) }
      it { expect(result.error).to eq(:cannot_destroy) }
    end

    context "when medical_shift is outside the given scope" do
      let(:medical_shift) { create(:medical_shift) }
      let(:empty_scope) { MedicalShift.none }

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          described_class.result(id: medical_shift.id.to_s, scope: empty_scope)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when medical_shift with given id doesn't exist" do
      subject(:result) { described_class.result(id: "nonexistent") }

      it { expect { result }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end
end
