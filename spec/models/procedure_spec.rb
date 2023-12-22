# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedure do
  describe "associations" do
    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:amount_cents) }

    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than_or_equal_to(0) }
  end

  describe "monetization" do
    it "monetizes amount attribute" do
      procedure = described_class.new(amount_cents: 10)

      expect(procedure.amount).to eq Money.new(10, "BRL")
    end
  end
end
