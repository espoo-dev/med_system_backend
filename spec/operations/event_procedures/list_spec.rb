# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::List, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.result(page: nil, per_page: nil)

      expect(result.success?).to be true
    end

    it "returns all event_procedures" do
      event_procedures = create_list(:event_procedure, 3)

      result = described_class.result(page: nil, per_page: nil)

      expect(result.event_procedures).to eq event_procedures
    end

    context "when has pagination via page and per_page" do
      it "paginates event_procedures" do
        create_list(:event_procedure, 8)
        result = described_class.result(page: "1", per_page: "5")

        expect(result.event_procedures.count).to eq 5
      end
    end
  end
end
