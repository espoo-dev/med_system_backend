# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedures::Update, type: :operation do
  describe ".result" do
    context "with valid attributes" do
      let!(:procedure) { create(:procedure) }

      it "updates procedure" do
        attributes = { name: "Procedure Test", code: "03.02.04.01-5", amount_cents: 1000 }
        described_class.result(id: procedure.id.to_s, attributes: attributes)

        expect(procedure.reload.attributes).to include(
          "name" => attributes[:name],
          "code" => attributes[:code],
          "amount_cents" => attributes[:amount_cents]
        )
      end

      it "returns success" do
        attributes = { name: "Procedure Test", code: "03.02.04.01-5", amount_cents: 1000 }
        result = described_class.result(id: procedure.id.to_s, attributes: attributes)

        expect(result).to be_success
      end
    end

    context "with invalid attributes" do
      let!(:procedure) { create(:procedure) }

      it "fails" do
        invalid_attributes = { name: nil, code: nil, amount_cents: nil }
        result = described_class.result(id: procedure.id.to_s, attributes: invalid_attributes)

        expect(result).to be_failure
      end

      it "returns invalid procedure" do
        invalid_attributes = { name: nil, code: nil, amount_cents: nil }
        result = described_class.result(id: procedure.id.to_s, attributes: invalid_attributes)

        expect(result.procedure).not_to be_valid
      end

      it "returns errors" do
        invalid_attributes = { name: nil, code: nil, amount_cents: nil }
        result = described_class.result(id: procedure.id.to_s, attributes: invalid_attributes)

        expect(result.procedure.errors.full_messages).to eq(
          [
            "Name can't be blank",
            "Code can't be blank",
            "Amount cents can't be blank",
            "Amount cents is not a number"
          ]
        )
      end
    end
  end
end
