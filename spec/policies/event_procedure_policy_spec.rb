# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedurePolicy do
  describe "Scope" do
    it "returns all event_procedures for user" do
      user = create(:user)
      event_procedure = create(:event_procedure, user: user)

      scope = described_class::Scope.new(user, EventProcedure.all).resolve

      expect(scope).to eq [event_procedure]
    end

    it "returns no event_procedures for unregistered user" do
      create(:event_procedure)
      scope = described_class::Scope.new(nil, EventProcedure.all).resolve

      expect(scope).to eq []
    end
  end

  describe "#index?" do
    it "returns true for user" do
      user = create(:user)

      expect(described_class.new(user, EventProcedure).index?).to be true
    end

    it "returns false for unregistered user" do
      expect(described_class.new(nil, EventProcedure).index?).to be false
    end
  end

  describe "#create?" do
    it "returns true for user" do
      user = create(:user)

      expect(described_class.new(user, EventProcedure).create?).to be true
    end

    it "returns false for unregistered user" do
      expect(described_class.new(nil, EventProcedure).create?).to be false
    end
  end

  describe "#update?" do
    it "returns true for user" do
      user = create(:user)
      event_procedure = create(:event_procedure, user: user)

      expect(described_class.new(user, event_procedure).update?).to be true
    end

    it "returns false for unregistered user" do
      event_procedure = create(:event_procedure)

      expect(described_class.new(nil, event_procedure).update?).to be false
    end
  end

  describe "#destroy?" do
    it "returns true for user" do
      user = create(:user)
      event_procedure = create(:event_procedure, user: user)

      expect(described_class.new(user, event_procedure).destroy?).to be true
    end

    it "returns false for unregistered user" do
      event_procedure = create(:event_procedure)

      expect(described_class.new(nil, event_procedure).destroy?).to be false
    end

    context "when belongs to other user" do
      let(:user) { create(:user) }
      let(:event_procedure) { create(:event_procedure) }

      it { expect(described_class.new(user, event_procedure).destroy?).to be false }
    end
  end
end
