# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedurePolicy do
  let(:user) { create(:user) }
  let(:event_procedure) { create(:event_procedure, user: user) }
  let(:other_event_procedure) { create(:event_procedure) }

  describe "Scope" do
    subject(:resolved_scope) { described_class::Scope.new(current_user, EventProcedure.all).resolve }

    before do
      event_procedure
      other_event_procedure
    end

    context "when user is the owner" do
      let(:current_user) { user }

      it "includes only the user's own records" do
        expect(resolved_scope).to eq [event_procedure]
      end
    end

    context "when user is nil" do
      let(:current_user) { nil }

      it "returns an empty scope" do
        expect(resolved_scope).to eq []
      end
    end

    context "when user is not the owner" do
      let(:current_user) { create(:user) }

      it "returns an empty scope" do
        expect(resolved_scope).to eq []
      end
    end
  end

  describe "permissions" do
    context "when has no user" do
      subject { described_class.new(nil, event_procedure) }

      it { is_expected.to forbid_all_actions }
    end

    context "when user is present" do
      subject { described_class.new(user, event_procedure) }

      it { is_expected.to permit_actions(%i[index create]) }
    end

    context "when user is owner" do
      subject { described_class.new(user, event_procedure) }

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end

    context "when user is not owner" do
      subject { described_class.new(user, other_event_procedure) }

      it { is_expected.to forbid_actions(%i[update destroy]) }
    end
  end
end
