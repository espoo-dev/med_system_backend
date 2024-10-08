# frozen_string_literal: true

require "rails_helper"

RSpec.describe HospitalPolicy do
  let(:user) { create(:user) }
  let(:hospital) { create(:hospital) }

  permissions :index?, :create?, :update?, :destroy? do
    context "when has user" do
      it { expect(described_class).to permit(user, hospital) }
    end

    context "when has no user" do
      it { expect(described_class).not_to permit(nil, hospital) }
    end
  end
end
