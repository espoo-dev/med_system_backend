# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }

  describe "#index" do
    context "when user is admin" do
      it { expect(described_class.new(admin, user).index?).to be true }
    end

    context "when user it not admin" do
      it { expect(described_class.new(user, user).index?).to be false }
    end
  end
end
