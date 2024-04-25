# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedures::ByCustomQuery do
  context "when custom is true" do
    it "returns only custom procedures" do
      user = create(:user)
      _old_custom_procedure = create(:procedure, name: "Procedure", custom: true, user: user, created_at: 1.day.ago)
      new_custom_procedure = create(:procedure, name: "Procedure", custom: true, user: user)
      _procedure = create(:procedure, custom: false)

      by_custom_query = described_class.call(custom: "true", user: user)

      expect(by_custom_query).to contain_exactly(new_custom_procedure)
    end
  end

  context "when custom is false" do
    it "returns only non-custom procedures" do
      user = create(:user)
      _custom_procedure = create(:procedure, custom: true, user: user)
      procedure = create(:procedure, custom: false)

      by_custom_query = described_class.call(custom: "false", user: user)

      expect(by_custom_query).to contain_exactly(procedure)
    end
  end
end
