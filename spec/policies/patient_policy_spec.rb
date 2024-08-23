# frozen_string_literal: true

require "rails_helper"

RSpec.describe PatientPolicy do
  let(:user) { create(:user) }
  let(:patient) { create(:patient, user: user) }
  let(:patient_without_user) { create(:patient) }

  describe PatientPolicy::Scope do
    subject(:result) { instance.resolve }

    let(:instance) { described_class.new(user, Patient.all) }

    context "when has user" do
      it { expect(result).to eq [patient] }
    end

    context "when has no user" do
      let(:user) { nil }

      it { expect(result).to eq [] }
    end
  end

  permissions :index?, :create? do
    context "when has no user" do
      it { expect(described_class).not_to permit(nil, patient) }
    end
  end

  permissions :update?, :destroy? do
    context "when user is not owner" do
      it { expect(described_class).not_to permit(user, patient_without_user) }
    end

    context "when user is owner" do
      it { expect(described_class).to permit(user, patient) }
    end
  end
end
