# frozen_string_literal: true

require "rails_helper"

RSpec.describe HospitalPolicy do
  let(:user) { create(:user) }
  let(:hospital) { create(:hospital) }

  permissions :index?, :create?, :update?, :destroy? do
    context "when user is present" do
      it { expect(described_class).to permit(user, hospital) }
    end

    context "when user is nil" do
      it { expect(described_class).not_to permit(nil, hospital) }
    end
  end
end
