# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::Destroy, type: :operation do
  describe ".result" do
    context "when event_procedure can be destroyed" do
      let!(:event_procedure) { create(:event_procedure) }

      it "is successful" do
        expect(described_class.result(id: event_procedure.id.to_s)).to be_success
      end

      it "destroys event_procedure" do
        expect { described_class.result(id: event_procedure.id.to_s) }.to change(EventProcedure, :count).by(-1)
      end
    end

    context "when event_procedure cannot be destroyed" do
      let!(:event_procedure) { create(:event_procedure) }

      it "is failure" do
        allow(EventProcedure).to receive(:find).with(event_procedure.id.to_s).and_return(event_procedure)
        allow(event_procedure).to receive(:destroy).and_return(false)

        expect(described_class.result(id: event_procedure.id.to_s)).to be_failure
      end

      it "does not destroy event_procedure" do
        allow(EventProcedure).to receive(:find).with(event_procedure.id.to_s).and_return(event_procedure)
        allow(event_procedure).to receive(:destroy).and_return(false)

        expect { described_class.result(id: event_procedure.id.to_s) }.not_to change(EventProcedure, :count)
      end

      it "returns error message" do
        allow(EventProcedure).to receive(:find).with(event_procedure.id.to_s).and_return(event_procedure)
        allow(event_procedure).to receive(:destroy).and_return(false)

        result = described_class.result(id: event_procedure.id.to_s)

        expect(result.error).to eq(:cannot_destroy)
      end
    end

    context "when event_procedure with given id doesn't exist" do
      it "raises ActiveRecord::RecordNotFound error" do
        expect { described_class.result(id: "nonexistent") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
