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

    context "when validating code uniqueness" do
      it "does not allow duplicate codes" do
        procedure = create(:procedure)
        new_procedure = build(:procedure, code: procedure.code)

        expect(new_procedure).not_to be_valid
        expect(new_procedure.errors[:code]).to include("has already been taken")
      end
    end
  end

  describe "monetization" do
    it "monetizes amount attribute" do
      procedure = described_class.new(amount_cents: 10)

      expect(procedure.amount).to eq Money.new(10, "BRL")
    end
  end
end
