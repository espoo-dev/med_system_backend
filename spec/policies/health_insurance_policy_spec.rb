# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurancePolicy do
  let(:user) { create(:user) }
  let(:health_insurance) { create(:health_insurance, user: user) }

  permissions :index?, :create? do
    context "when has user" do
      it { expect(described_class).to permit(user, health_insurance) }
    end

    context "when has no user" do
      it { expect(described_class).not_to permit(nil, health_insurance) }
    end
  end
end
