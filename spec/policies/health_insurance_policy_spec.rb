# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurancePolicy do
  let(:user) { create(:user) }
  let(:health_insurance) { create(:health_insurance, user: user) }

  describe "permissions" do
    context "when has user" do
      subject { described_class.new(user, health_insurance) }

      it { is_expected.to permit_actions(%i[index create]) }
    end

    context "when has no user" do
      subject { described_class.new(nil, health_insurance) }

      it { is_expected.to forbid_actions(%i[index create]) }
    end
  end
end
