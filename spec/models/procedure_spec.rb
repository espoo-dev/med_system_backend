# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedure do
  describe "associations" do
    it { is_expected.to belong_to(:user).optional(true) }

    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:amount_cents) }

    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than_or_equal_to(0) }

    context "when validating code uniqueness" do
      it "does not allow duplicate codes" do
        create(:procedure, code: "old_code")
        new_procedure = build(:procedure, code: "oLd_cOdE")

        expect(new_procedure).not_to be_valid
        expect(new_procedure.errors[:code]).to include("has already been taken")
      end
    end

    context "when custom is true" do
      it "validates presence of user_id" do
        procedure = described_class.new(
          name: "Procedure name",
          code: "Procedure code",
          amount_cents: 100,
          description: "Procedure description",
          custom: true,
          user_id: nil
        )

        expect(procedure).not_to be_valid
        expect(procedure.errors[:user_id]).to include("can't be blank")
      end
    end

    context "when custom is false" do
      it "does not validate presence of user_id" do
        procedure = described_class.new(
          name: "Procedure name",
          code: "Procedure code",
          amount_cents: 100,
          description: "Procedure description",
          custom: false,
          user_id: nil
        )

        expect(procedure).to be_valid
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
