# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedures::List, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.result

      expect(result).to be_success
    end

    it "returns all procedures ordered by created_at desc" do
      today_procedure = create(:procedure, created_at: Time.zone.today)
      tomorrow_procedure = create(:procedure, created_at: Time.zone.tomorrow)
      yesterday_procedure = create(:procedure, created_at: Time.zone.yesterday)

      result = described_class.result

      expect(result.procedures).to eq(
        [
          tomorrow_procedure,
          today_procedure,
          yesterday_procedure
        ]
      )
    end

    it "returns all procedures ignoring default per_page value" do
      procedures = create_list(:procedure, 26)

      result = described_class.result

      expect(result.procedures.count).to eq(procedures.count)
      expect(result.procedures).to match_array(procedures)
    end

    context "when custom is true" do
      it "returns only the custom procedures for the given user" do
        user = create(:user)
        custom_procedure = create(:procedure, custom: true, user: user)
        _non_custom_procedure = create(:procedure, custom: false)

        result = described_class.result(params: { custom: "true" }, user: user)

        expect(result.procedures).to contain_exactly(custom_procedure)
      end
    end

    context "when custom is false" do
      it "returns only the non-custom procedures" do
        user = create(:user)
        _custom_procedure = create(:procedure, custom: true, user: user)
        non_custom_procedure = create(:procedure, custom: false)

        result = described_class.result(params: { custom: "false" }, user: user)

        expect(result.procedures).to contain_exactly(non_custom_procedure)
      end
    end
  end

  context "when has pagination via page and per_page" do
    it "paginate the procedures" do
      create_list(:procedure, 8)

      result = described_class.result(params: { page: 1, per_page: 5 })

      expect(result.procedures.count).to eq 5
    end
  end
end
