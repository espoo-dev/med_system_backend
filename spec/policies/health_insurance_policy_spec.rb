# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurancePolicy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:health_insurance) { create(:health_insurance, user: user) }

  permissions :index?, :create? do
    context "when user is present" do
      it { is_expected.to permit(user, health_insurance) }
    end

    context "when user is nil" do
      it { is_expected.not_to permit(nil, health_insurance) }
    end
  end
end
