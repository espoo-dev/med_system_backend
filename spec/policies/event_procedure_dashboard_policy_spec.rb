# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedureDashboardPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let(:event_procedure) { create(:event_procedure) }

  permissions :amount_by_day? do
    subject { described_class }

    context "when the user is an admin" do
      it { is_expected.to permit(admin, event_procedure) }
    end

    context "when the user is not an admin" do
      it { is_expected.not_to permit(user, event_procedure) }
    end
  end
end
