# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationPolicy do
  describe "#owner?" do
    context "when user is the owner of the record" do
      it "returns true" do
        user = create(:user)
        record = create(:medical_shift, user: user)

        expect(described_class.new(user, record).owner?).to be true
      end
    end

    context "when user is not the owner of the record" do
      it "returns false" do
        another_user = create(:user)
        record = create(:medical_shift, user: create(:user))

        expect(described_class.new(another_user, record).owner?).to be false
      end
    end
  end

  it "returns false for #index?" do
    expect(described_class.new(nil, nil).index?).to be false
  end

  it "returns false for #show?" do
    expect(described_class.new(nil, nil).show?).to be false
  end

  it "returns false for #create?" do
    expect(described_class.new(nil, nil).create?).to be false
  end

  it "returns false for #new?" do
    expect(described_class.new(nil, nil).new?).to be false
  end

  it "returns false for #update?" do
    expect(described_class.new(nil, nil).update?).to be false
  end

  it "returns false for #edit?" do
    expect(described_class.new(nil, nil).edit?).to be false
  end

  it "returns false for #destroy?" do
    expect(described_class.new(nil, nil).destroy?).to be false
  end

  context "when #resolve is not defined" do
    it "raises NotImplementedError" do
      expect { described_class::ApplicationScope.new(nil, nil).resolve }.to raise_error(NotImplementedError)
    end
  end
end
