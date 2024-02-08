# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftPolicy do
  describe "Scope" do
    it "returns all medical_shifts for user" do
      user = create(:user)
      medical_shift = create(:medical_shift, user: user)

      scope = described_class::Scope.new(user, MedicalShift.all).resolve

      expect(scope).to eq [medical_shift]
    end

    it "returns no medical_shifts for unregistered user" do
      create(:medical_shift)
      scope = described_class::Scope.new(nil, MedicalShift.all).resolve

      expect(scope).to eq []
    end
  end

  describe "#index?" do
    it "returns true for user" do
      user = create(:user)

      expect(described_class.new(user, MedicalShift).index?).to be true
    end

    it "returns false for unregistered user" do
      expect(described_class.new(nil, MedicalShift).index?).to be false
    end
  end

  describe "#create?" do
    it "returns true for user" do
      user = create(:user)

      expect(described_class.new(user, MedicalShift).create?).to be true
    end

    it "returns false for unregistered user" do
      expect(described_class.new(nil, MedicalShift).create?).to be false
    end
  end
end
