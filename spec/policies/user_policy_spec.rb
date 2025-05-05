# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }

  describe "permissions" do
    context "when user is admin" do
      subject {described_class.new(admin, user)}

      it { is_expected.to permit_actions(%i[index]) }
    end

    context "when user is not admin" do
      subject {described_class.new(user, user)}

      it { is_expected.to forbid_actions(%i[index]) }
    end
  end
end
