# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProcedurePolicy do
  let(:user) { create(:user) }
  let(:procedure) { create(:procedure, user: user) }
  let(:procedure_without_user) { create(:procedure) }

  permissions :index?, :create? do
    context "when has no user" do
      it { expect(described_class).not_to permit(nil, procedure) }
    end
  end

  permissions :update?, :destroy? do
    context "when user is not owner" do
      it { expect(described_class).not_to permit(user, procedure_without_user) }
    end

    context "when user is owner" do
      it { expect(described_class).to permit(user, procedure) }
    end
  end
end
