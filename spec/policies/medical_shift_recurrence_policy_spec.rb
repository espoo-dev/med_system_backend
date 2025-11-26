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

      it "does not include deleted recurrences by default" do
        expect(policy_scope).to include(medical_shift_recurrence)
        expect(policy_scope).not_to include(deleted_recurrence)
      end

      it "can include deleted recurrences when using with_deleted" do
        scope_with_deleted = described_class::Scope.new(
          current_user,
          MedicalShiftRecurrence.with_deleted
        ).resolve

        expect(scope_with_deleted).to include(medical_shift_recurrence, deleted_recurrence)
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
