# frozen_string_literal: true

require "rails_helper"

RSpec.describe PatientPolicy do
  let(:user) { create(:user) }
  let(:patient) { create(:patient, user: user) }
  let(:patient_another_user) { create(:patient) }

  describe "Scope" do
    subject(:policy_scope) { described_class::Scope.new(current_user, Patient.all).resolve }

    before do
      patient
      patient_another_user
    end

    context "when user is the owner" do
      let(:current_user) { user }

      it { is_expected.to eq [patient] }
    end

    context "when user is nil" do
      let(:current_user) { nil }

      it { is_expected.to eq [] }
    end

    context "when user is not the owner" do
      let(:current_user) { create(:user) }

      it { is_expected.to eq [] }
    end
  end

  permissions :index?, :create? do
    context "when user is nil" do
      it { expect(described_class).not_to permit(nil, patient) }
    end
  end

  permissions :update?, :destroy? do
    context "when user is not the owner" do
      it { expect(described_class).not_to permit(user, patient_another_user) }
    end

    context "when user is the owner" do
      it { expect(described_class).to permit(user, patient) }
    end
  end
end
