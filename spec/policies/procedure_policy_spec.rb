# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProcedurePolicy do
  let(:user) { create(:user) }
  let(:procedure) { create(:procedure, user: user) }
  let(:procedure_without_user) { create(:procedure) }

  describe "permissions" do
    context "when has no user" do
      subject { described_class.new(nil, procedure) }

      it { is_expected.to forbid_all_actions }
    end

    context "when user is present" do
      subject { described_class.new(user, procedure) }

      it { is_expected.to permit_actions(%i[index create]) }
    end

    context "when user is owner" do
      subject { described_class.new(user, procedure) }

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end

    context "when user is not owner" do
      subject { described_class.new(user, procedure_without_user) }

      it { is_expected.to forbid_actions(%i[update destroy]) }
    end
  end
end
