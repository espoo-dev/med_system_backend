# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }

  permissions :index? do
    context "when user is admin" do
      it { expect(described_class).to permit(admin, user) }
    end

    context "when user is not admin" do
      it { expect(described_class).not_to permit(user, user) }
    end
  end
end
