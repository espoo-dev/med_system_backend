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

  describe "permissions" do
    context "when has user" do
      subject { described_class.new(user, medical_shift) }

      it { is_expected.to permit_actions(%i[index create hospital_name_suggestion_index amount_suggestions_index]) }
    end

    context "when has no user" do
      subject { described_class.new(nil, medical_shift) }

      it { is_expected.to forbid_all_actions }
    end

    context "when user is owner" do
      subject { described_class.new(user, medical_shift) }

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end

    context "when user is not owner" do
      subject { described_class.new(user, medical_shift_without_user) }

      it { is_expected.to forbid_actions(%i[update destroy]) }
    end
  end
end
