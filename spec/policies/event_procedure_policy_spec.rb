# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedurePolicy do
  let(:user) { create(:user) }
  let(:event_procedure) { create(:event_procedure, user: user) }
  let(:event_procedure_without_user) { create(:event_procedure) }

  describe EventProcedurePolicy::Scope do
    subject(:result) { instance.resolve }

    let(:instance) { described_class.new(user, EventProcedure.all) }

    context "when has user" do
      it { expect(result).to eq [event_procedure] }
    end

    context "when has no user" do
      let(:user) { nil }

      it { expect(result).to eq [] }
    end
  end

  permissions :index?, :create? do
    context "when has no user" do
      it { expect(described_class).not_to permit(nil, event_procedure) }
    end
  end

  permissions :update?, :destroy? do
    context "when user is owner" do
      it { expect(described_class).to permit(user, event_procedure) }
    end

    context "when user is not owner" do
      it { expect(described_class).not_to permit(user, event_procedure_without_user) }
    end
  end
end
