# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedures::Create, type: :operation do
  describe ".result" do
    context "when params are valid" do
      it "is successful" do
        attributes = { name: "Procedure 1", code: "PROC1", amount_cents: 1000, custom: false }

        result = described_class.result(attributes: attributes)

        expect(result).to be_success
      end

      it "creates a procedure" do
        attributes = { name: "Procedure 1", code: "PROC1", amount_cents: 1000, custom: false }

        result = described_class.result(attributes: attributes)

        expect(result.procedure).to be_persisted

        expect(result.procedure.attributes.symbolize_keys).to include(
          name: attributes[:name],
          code: attributes[:code],
          amount_cents: attributes[:amount_cents]
        )
      end

      context "when custom attribute is true" do
        it "associates the current user" do
          user = create(:user)
          attributes = { name: "Procedure 1", code: "PROC1", amount_cents: 1000, custom: true }

          result = described_class.result(attributes: attributes, user: user)

          expect(result.procedure.user).to eq(user)
        end
      end

      context "when custom attribute is false" do
        it "does not associate the current user" do
          user = create(:user)
          attributes = { name: "Procedure 1", code: "PROC1", amount_cents: 1000, custom: false }

          result = described_class.result(attributes: attributes, user: user)

          expect(result.procedure.user).to be_nil
        end
      end
    end

    context "when params are invalid" do
      it "is failure" do
        invalid_attributes = { name: nil, code: nil }

        result = described_class.result(attributes: invalid_attributes)

        expect(result).to be_failure
      end

      it "returns a invalid procedure" do
        invalid_attributes = { name: nil, code: nil }

        result = described_class.result(attributes: invalid_attributes)

        expect(result.procedure).not_to be_valid
      end

      it "returns error messages" do
        invalid_attributes = { name: nil, code: nil }

        result = described_class.result(attributes: invalid_attributes)

        expect(result.procedure.errors.full_messages).to eq(["Name can't be blank", "Code can't be blank"])
      end
    end
  end
end
