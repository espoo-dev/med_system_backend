# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedure do
  describe "associations" do
    it { is_expected.to belong_to(:user).optional(true) }

    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:amount_cents) }

    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than_or_equal_to(0) }

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

      it "does not validates presence of code" do
        user = create(:user)
        new_procedure = build(:procedure, custom: true, code: nil, user: user)

        expect(new_procedure).to be_valid
        expect(new_procedure.errors).to be_empty
      end

      it "does not validates code uniqueness" do
        user = create(:user)
        create(:procedure, custom: true, code: "old_code", user: user)
        new_procedure = build(:procedure, custom: true, code: "oLd_cOdE", user: user)

        expect(new_procedure).to be_valid
        expect(new_procedure.errors).to be_empty
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

      it "validates code uniqueness" do
        create(:procedure, custom: false, code: "old_code")
        new_procedure = build(:procedure, custom: false, code: "oLd_cOdE")

        expect(new_procedure).not_to be_valid
        expect(new_procedure.errors[:code]).to include("has already been taken")
      end

      it "validates presence of code" do
        new_procedure = build(:procedure, custom: false, code: nil)

        expect(new_procedure).not_to be_valid
        expect(new_procedure.errors.full_messages).to eq(["Code can't be blank"])
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
