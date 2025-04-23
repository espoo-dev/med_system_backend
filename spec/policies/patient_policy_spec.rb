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

  describe "permissions" do
    context "when user is nil" do
      subject { described_class.new(nil, patient) }

      it { is_expected.to forbid_all_actions }
    end

    context "when user is present" do
      subject { described_class.new(user, patient) }

      it { is_expected.to permit_actions(%i[index create]) }
    end

    context "when user is owner" do
      subject { described_class.new(user, patient) }

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end

    context "when user is not owner" do
      subject { described_class.new(user, patient_another_user) }

      it { is_expected.to forbid_actions(%i[update destroy]) }
    end
  end
end
