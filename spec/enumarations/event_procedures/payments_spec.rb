# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::Payments, type: :enumeration do
  describe ".list" do
    it "returns payments" do
      expect(described_class.list).to eq(%w[health_insurance others])
    end
  end
end
