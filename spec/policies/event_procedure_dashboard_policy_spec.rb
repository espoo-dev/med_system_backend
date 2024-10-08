# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedureDashboardPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let(:event_procedure) { create(:event_procedure) }

  permissions :amount_by_day? do
    context "when user is admin" do
      it { expect(described_class).to permit(admin, event_procedure) }
    end

    context "when user is not admin" do
      it { expect(described_class).not_to permit(user, event_procedure) }
    end
  end
end
