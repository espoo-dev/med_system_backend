# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedurePolicy do
  let(:user) { create(:user) }
  let(:event_procedure) { create(:event_procedure, user: user) }
  let(:other_user_event_preocedure) { create(:event_procedure) }

  describe EventProcedurePolicy::Scope do
    subject(:result) { instance.resolve }

    let(:instance) { described_class.new(user, EventProcedure.all) }

    before do
      event_procedure
      other_user_event_preocedure
    end

    context "when has user" do
      it { expect(result).to eq [event_procedure] }
    end

    context "when has no user" do
      let(:instance) { described_class.new(nil, EventProcedure.all) }

      it { expect(result).to eq [] }
    end

    context "when user is not owner" do
      let(:another_user) { create(:user) }
      let(:instance) { described_class.new(another_user, EventProcedure.all) }

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
      it { expect(described_class).not_to permit(user, other_user_event_preocedure) }
    end
  end
end
