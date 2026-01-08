# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedures::Find, type: :operation do
  describe ".result" do
    context "when procedure with given id exists" do
      let(:procedure) { create(:procedure) }

      it "returns found procedure" do
        result = described_class.result(id: procedure.id.to_s)

        expect(result.procedure).to eq(procedure)
      end

      it "is successful" do
        result = described_class.result(id: procedure.id.to_s)

        expect(result).to be_success
      end
    end

    context "when procedure with given id does not exist" do
      it "raises ActiveRecord::RecordNotFound error" do
        expect do
          described_class.result(id: "non-existing-id")
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when using a scope" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:procedure) { create(:procedure, custom: true, user: user) }
      let(:other_procedure) { create(:procedure, custom: true, user: other_user) }

      it "returns found procedure when it exists in scope" do
        result = described_class.result(
          id: procedure.id.to_s,
          scope: Procedure.where(user: user)
        )

        expect(result.procedure).to eq(procedure)
      end

      it "raises ActiveRecord::RecordNotFound when record exists but not in scope" do
        expect do
          described_class.result(
            id: other_procedure.id.to_s,
            scope: Procedure.where(user: user)
          )
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
