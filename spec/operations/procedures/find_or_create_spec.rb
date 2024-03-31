# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedures::FindOrCreate, type: :operation do
  describe ".result" do
    context "when procedure with given id exists" do
      it "is successful" do
        procedure = create(:procedure)
        params = { id: procedure.id }

        result = described_class.result(params: params)

        expect(result).to be_success
      end

      it "returns found procedure" do
        procedure = create(:procedure)
        params = { id: procedure.id }

        result = described_class.result(params: params)

        expect(result.procedure).to eq(procedure)
      end
    end

    context "when procedure with given id does not exist" do
      it "is successful" do
        user = create(:user)
        params = {
          id: nil,
          name: "procedure name",
          code: "code-1234",
          amount_cents: 100,
          description: "procedure description",
          custom: true,
          user_id: user.id
        }

        result = described_class.result(params: params)

        expect(result).to be_success
      end

      it "creates a procedure" do
        user = create(:user)
        params = {
          id: nil,
          name: "procedure name",
          code: "code-1234",
          amount_cents: 100,
          description: "procedure description",
          custom: true,
          user_id: user.id
        }

        result = described_class.result(params: params)

        expect(result.procedure).to be_persisted
        expect(result.procedure.code).to eq("code-1234")
      end
    end

    context "when params are empty" do
      it "is failure" do
        params = {
          id: nil,
          name: nil,
          code: nil,
          amount_cents: nil,
          description: nil,
          custom: true,
          user_id: nil
        }

        result = described_class.result(params: params)

        expect(result).to be_failure
      end

      it "returns errors" do
        _some_procedure = create(:procedure, code: "code-1234")
        params = {
          id: nil,
          name: nil,
          code: "code-1234",
          amount_cents: nil,
          description: nil,
          custom: true,
          user_id: nil
        }

        result = described_class.result(params: params)

        expect(result.error).to eq(:invalid_record)
        expect(result.procedure.errors.full_messages).to eq(
          [
            "Name can't be blank",
            "Amount cents can't be blank",
            "User can't be blank",
            "Amount cents is not a number",
            "Code has already been taken"
          ]
        )
      end
    end
  end
end
