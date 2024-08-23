# frozen_string_literal: true

require "rails_helper"

RSpec.describe PatientPolicy do
  let(:user) { create(:user) }
  let(:patient_user) { create(:patient, user: user) }
  let(:patient_no_user) { create(:patient) }

  describe "Scope" do
    subject(:scope) { instance.resolve }

    context "when registered user" do
      let(:instance) { described_class::Scope.new(user, Patient.all) }

      it { expect(scope).to eq [patient_user] }
    end

    context "when unregistered user" do
      let(:instance) { described_class::Scope.new(nil, Patient.all) }

      it { expect(scope).to eq [] }
    end
  end

  describe "#index" do
    context "when patient has user" do
      it { expect(described_class.new(user, patient_user).index?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, patient_no_user).index?).to be false }
    end
  end

  describe "#create" do
    context "when patient has user" do
      it { expect(described_class.new(user, patient_user).create?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, patient_no_user).create?).to be false }
    end
  end

  describe "#update" do
    context "when patient has user" do
      it { expect(described_class.new(user, patient_user).update?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, patient_no_user).update?).to be false }
    end

    context "when belongs to other owner" do
      it { expect(described_class.new(user, patient_no_user).update?).to be false }
    end
  end

  describe "#delete?" do
    context "when patient has user" do
      it { expect(described_class.new(user, patient_user).destroy?).to be true }
    end

    context "when does not have a user" do
      it { expect(described_class.new(nil, patient_no_user).destroy?).to be false }
    end

    context "when belongs to other owner" do
      it { expect(described_class.new(user, patient_no_user).destroy?).to be false }
    end
  end
end
