# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftRecurrence do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:medical_shifts).dependent(:nullify) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:frequency) }
    it { is_expected.to validate_inclusion_of(:frequency).in_array(MedicalShiftRecurrence::FREQUENCIES) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:workload) }
    it { is_expected.to validate_presence_of(:start_hour) }
    it { is_expected.to validate_presence_of(:hospital_name) }
    it { is_expected.to validate_presence_of(:amount_cents) }

    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than_or_equal_to(0) }

    it { is_expected.to allow_value("#FF00aa").for(:color) }
    it { is_expected.not_to allow_value("FF00aa").for(:color) }
    it { is_expected.not_to allow_value("#fff").for(:color) }
    it { is_expected.not_to allow_value("#ff00aaff").for(:color) }
    it { is_expected.not_to allow_value("#ff00zz").for(:color) }
    it { is_expected.not_to allow_value("random value").for(:color) }
    it { is_expected.not_to allow_value("").for(:color) }

    context "when frequency is weekly" do
      it "requires day_of_week to be present and valid" do
        weekly = build(:medical_shift_recurrence, :weekly, day_of_week: nil)

        expect(weekly).not_to be_valid
        expect(weekly.errors[:day_of_week]).to include("can't be blank")
      end

      it "validates day_of_week is between 0 and 6" do
        weekly = build(:medical_shift_recurrence, :weekly, day_of_week: 7)

        expect(weekly).not_to be_valid
        expect(weekly.errors[:day_of_week]).to include("must be in 0..6")
      end

      it "does not allow day_of_month to be present" do
        weekly = build(:medical_shift_recurrence, :weekly, day_of_month: 15)

        expect(weekly).not_to be_valid
        expect(weekly.errors[:day_of_month]).to include("It must be empty for weekly/biweekly recurrence.")
      end
    end

    context "when frequency is biweekly" do
      it "requires day_of_week to be present and valid" do
        biweekly = build(:medical_shift_recurrence, :biweekly, day_of_week: nil)

        expect(biweekly).not_to be_valid
        expect(biweekly.errors[:day_of_week]).to include("can't be blank")
      end
    end

    context "when frequency is monthly_fixed_day" do
      it "requires day_of_month to be present and valid" do
        monthly = build(:medical_shift_recurrence, :monthly_fixed_day, day_of_month: nil)

        expect(monthly).not_to be_valid
        expect(monthly.errors[:day_of_month]).to include("can't be blank")
      end

      it "validates day_of_month is between 1 and 31" do
        monthly = build(:medical_shift_recurrence, :monthly_fixed_day, day_of_month: 32)

        expect(monthly).not_to be_valid
        expect(monthly.errors[:day_of_month]).to include("must be in 1..31")
      end

      it "does not allow day_of_week to be present" do
        monthly = build(:medical_shift_recurrence, :monthly_fixed_day, day_of_week: 2)

        expect(monthly).not_to be_valid
        expect(monthly.errors[:day_of_week]).to include("It must be empty for monthly_fixed_day recurrence.")
      end
    end
  end

  describe ".enumerations" do
    it "has enumerations for workload" do
      expect(described_class.enumerations).to include(workload: MedicalShifts::Workloads)
    end
  end

  describe "monetization" do
    it "monetizes amount attribute" do
      medical_shift_recurrence = described_class.new(amount_cents: 10)

      expect(medical_shift_recurrence.amount).to eq Money.new(10, "BRL")
      expect(medical_shift_recurrence.amount.format).to eq "R$0.10"
    end
  end
end
