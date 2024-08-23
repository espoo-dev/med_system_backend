# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurancePolicy do
  let(:user) { create(:user) }
  let(:health_insurance_user) { create(:health_insurance, user: user) }
  let(:health_insurance_no_user) { create(:health_insurance) }

  describe "#index" do
    context "when health_insurance has user" do
      it { expect(described_class.new(user, health_insurance_user).index?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, health_insurance_no_user).index?).to be false }
    end
  end

  describe "#create" do
    context "when health_insurance has user" do
      it { expect(described_class.new(user, health_insurance_user).create?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, health_insurance_no_user).create?).to be false }
    end
  end
end
