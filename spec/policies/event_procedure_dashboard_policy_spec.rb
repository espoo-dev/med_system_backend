# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedureDashboardPolicy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let(:event_procedure) { create(:event_procedure) }

  describe "#amount_by_day?" do
    context "when user is admin" do
      it { expect(described_class.new(admin, event_procedure).amount_by_day?).to be true }
    end

    context "when user it not admin" do
      it { expect(described_class.new(user, event_procedure).amount_by_day?).to be false }
    end
  end
end
