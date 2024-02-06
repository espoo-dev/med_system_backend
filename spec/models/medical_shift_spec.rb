# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShift do
  describe "associations" do
    it { is_expected.to belong_to(:hospital) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:workload) }
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:amount_cents) }

    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than_or_equal_to(0) }
  end

  describe ".enumerations" do
    it "has enumerations for workload" do
      expect(described_class.enumerations).to include(workload: MedicalShifts::Workloads)
    end
  end

  describe "monetization" do
    it "monetizes amount attribute" do
      medical_shift = described_class.new(amount_cents: 10)

      expect(medical_shift.amount).to eq Money.new(10, "BRL")
      expect(medical_shift.amount.format).to eq "R$0.10"
    end
  end
end
