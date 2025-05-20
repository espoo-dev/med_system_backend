# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShift do
  describe "soft delete behavior" do
    let(:user) { create(:user) }
    let(:medical_shift) { create(:medical_shift, user: user) }

    it_behaves_like "acts as paranoid", :medical_shift
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:workload) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:start_hour) }
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

  describe ".shift" do
    subject(:shift) { medical_shift.shift }

    context "when is daytime" do
      context "when after 12am" do
        let(:medical_shift) { create(:medical_shift, start_hour: "18:59") }

        it { expect(shift).to eq("Daytime") }
      end

      context "when before 12am" do
        let(:medical_shift) { create(:medical_shift, start_hour: "07:00") }

        it { expect(shift).to eq("Daytime") }
      end
    end

    context "when is nighttime" do
      context "when after 12am" do
        let(:medical_shift) { create(:medical_shift, start_hour: "19:00") }

        it { expect(shift).to eq("Nighttime") }
      end

      context "when before 12am" do
        let(:medical_shift) { create(:medical_shift, start_hour: "6:59") }

        it { expect(shift).to eq("Nighttime") }
      end
    end
  end

  describe ".title" do
    subject(:shift) { medical_shift.title }

    context "when is daytime" do
      let(:medical_shift) { create(:medical_shift, workload: :six) }

      it { expect(shift).to eq("#{medical_shift.hospital_name} | 6h | Daytime") }
    end

    context "when is nighttime" do
      let(:medical_shift) { create(:medical_shift, start_hour: "22:00", workload: :twenty_four) }

      it { expect(shift).to eq("#{medical_shift.hospital_name} | 24h | Nighttime") }
    end
  end
end
