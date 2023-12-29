# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedures::Create, type: :operation do
  describe ".result" do
    context "when params are valid" do
      let!(:attributes) do
        { name: "Test Procedure", code: "03.02.04.01-5", amount_cents: 1000 }
      end

      it "is successful" do
        result = described_class.result(attributes: attributes)

        expect(result).to be_success
      end

      it "creates a procedure" do
        result = described_class.result(attributes: attributes)

        expect(result.procedure).to be_persisted

        expect(result.procedure.attributes.symbolize_keys).to include(
          name: attributes[:name],
          code: attributes[:code],
          amount_cents: attributes[:amount_cents]
        )
      end
    end

    context "when params are invalid" do
      let!(:invalid_attributes) { { name: nil, code: nil } }

      it "is failure" do
        result = described_class.result(attributes: invalid_attributes)

        expect(result).to be_failure
      end

      it "returns a invalid procedure" do
        result = described_class.result(attributes: invalid_attributes)

        expect(result.procedure).not_to be_valid
      end

      it "returns error messages" do
        result = described_class.result(attributes: invalid_attributes)

        expect(result.procedure.errors.full_messages).to eq(["Name can't be blank", "Code can't be blank"])
      end
    end
  end
end
