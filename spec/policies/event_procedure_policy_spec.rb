# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedurePolicy do
  subject(:policy) { described_class }

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

  permissions :index?, :create? do
    context "when user is nil" do
      it { is_expected.not_to permit(nil, event_procedure) }
    end

    context "when user is present" do
      it { is_expected.to permit(user, event_procedure) }
    end
  end

  permissions :update?, :destroy? do
    it { is_expected.to permit(user, event_procedure) }
    it { is_expected.not_to permit(user, other_event_procedure) }
  end
end
