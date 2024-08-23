# frozen_string_literal: true

require "rails_helper"

RSpec.describe HospitalPolicy do
  let(:user) { create(:user) }
  let(:hospital) { create(:hospital) }

  describe "#index" do
    context "when hospital has user" do
      it { expect(described_class.new(user, hospital).index?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, hospital).index?).to be false }
    end
  end

  describe "#create" do
    context "when hospital has user" do
      it { expect(described_class.new(user, hospital).create?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, hospital).create?).to be false }
    end
  end

  describe "#update" do
    context "when hospital has user" do
      it { expect(described_class.new(user, hospital).update?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, hospital).update?).to be false }
    end
  end

  describe "#delete?" do
    context "when hospital has user" do
      it { expect(described_class.new(user, hospital).destroy?).to be true }
    end

    context "when does not have a user" do
      it { expect(described_class.new(nil, hospital).destroy?).to be false }
    end
  end
end
