# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProcedurePolicy do
  let(:user) { create(:user) }
  let(:procedure_user) { create(:procedure, user: user) }
  let(:procedure_no_user) { create(:procedure) }

  describe "#index" do
    context "when procedure has user" do
      it { expect(described_class.new(user, procedure_user).index?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, procedure_no_user).index?).to be false }
    end
  end

  describe "#create" do
    context "when procedure has user" do
      it { expect(described_class.new(user, procedure_user).create?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, procedure_no_user).create?).to be false }
    end
  end

  describe "#update" do
    context "when procedure has user" do
      it { expect(described_class.new(user, procedure_user).update?).to be true }
    end

    context "when unregistered user" do
      it { expect(described_class.new(nil, procedure_no_user).update?).to be false }
    end

    context "when belongs to other owner" do
      it { expect(described_class.new(user, procedure_no_user).update?).to be false }
    end
  end

  describe "#delete?" do
    context "when procedure has user" do
      it { expect(described_class.new(user, procedure_user).destroy?).to be true }
    end

    context "when does not have a user" do
      it { expect(described_class.new(nil, procedure_no_user).destroy?).to be false }
    end

    context "when belongs to other owner" do
      it { expect(described_class.new(user, procedure_no_user).destroy?).to be false }
    end
  end
end
