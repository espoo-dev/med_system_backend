# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::CalculateTotalAmount, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.call

      expect(result.success?).to be true
    end

    it "returns total amount cents" do
      create_list(:event_procedure, 3, procedure: create(:procedure, amount_cents: 1000))

      total = described_class.call.total

      expect(total).to eq "R$30.00"
    end
  end
end
