# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftPolicy do
  let(:user) { create(:user) }
  let(:medical_shift) { create(:medical_shift, user: user) }
  let(:medical_shift_without_user) { create(:medical_shift) }

  describe "Scope" do
    subject(:policy_scope) { described_class::Scope.new(current_user, MedicalShift.all).resolve }

    context "when user is present" do
      let(:current_user) { user }

      before do
        medical_shift
        medical_shift_without_user
      end

      it { is_expected.to eq [medical_shift] }
    end

    context "when user is nil" do
      let(:current_user) { nil }

      before do
        medical_shift
        medical_shift_without_user
      end

      it { is_expected.to eq [] }
    end
  end

  permissions :index?, :create? do
    context "when user is present" do
      it { expect(described_class).to permit(user, medical_shift) }
    end

    context "when user is nil" do
      it { expect(described_class).not_to permit(nil, medical_shift) }
    end
  end

  permissions :update?, :destroy? do
    context "when user is owner" do
      it { expect(described_class).to permit(user, medical_shift) }
    end

    context "when user is nil" do
      it { expect(described_class).not_to permit(nil, medical_shift) }
    end

    context "when user is not owner" do
      it { expect(described_class).not_to permit(user, medical_shift_without_user) }
    end
  end
end
