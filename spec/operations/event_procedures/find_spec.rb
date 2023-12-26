# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::Find, type: :operation do
  describe ".result" do
    context "when event_procedure with given id exists" do
      let(:event_procedure) { create(:event_procedure) }

      it "returns found event_procedure" do
        result = described_class.result(id: event_procedure.id.to_s)

        expect(result.event_procedure).to eq(event_procedure)
      end

      it "is successful" do
        result = described_class.result(id: event_procedure.id.to_s)

        expect(result).to be_success
      end
    end

    context "when event_procedure with given id does not exist" do
      it "raises ActiveRecord::RecordNotFound error" do
        expect do
          described_class.result(id: "non-existing-id")
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
