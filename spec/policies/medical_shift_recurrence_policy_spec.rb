# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftRecurrencePolicy do
  let(:user) { create(:user) }
  let(:medical_shift_recurrence) { create(:medical_shift_recurrence, user: user) }
  let(:other_user_recurrence) { create(:medical_shift_recurrence) }

  describe "Scope" do
    subject(:policy_scope) do
      described_class::Scope.new(current_user, MedicalShiftRecurrence.all).resolve
    end

    context "when user is present" do
      let(:current_user) { user }

      before do
        medical_shift_recurrence
        other_user_recurrence
      end

      it "returns only current user recurrences" do
        expect(policy_scope).to eq([medical_shift_recurrence])
      end

      it "does not return other users recurrences" do
        expect(policy_scope).not_to include(other_user_recurrence)
      end
    end

    context "when user is nil" do
      let(:current_user) { nil }

      before do
        medical_shift_recurrence
        other_user_recurrence
      end

      it "returns empty relation" do
        expect(policy_scope).to be_empty
      end
    end

    context "with deleted recurrences" do
      let(:current_user) { user }
      let!(:deleted_recurrence) do
        create(:medical_shift_recurrence, :deleted, user: user)
      end

      before do
        medical_shift_recurrence
      end

      it "includes deleted recurrences in scope" do
        # NOTE: O scope não filtra deleted_at, isso é feito no controller
        expect(policy_scope).to include(medical_shift_recurrence, deleted_recurrence)
      end
    end
  end

  describe "permissions" do
    context "when user is present" do
      subject { described_class.new(user, MedicalShiftRecurrence) }

      it { is_expected.to permit_actions(%i[index create]) }
    end

    context "when user is nil" do
      subject { described_class.new(nil, MedicalShiftRecurrence) }

      it { is_expected.to forbid_actions(%i[index create]) }
    end
  end
end
