# frozen_string_literal: true

require "rails_helper"

RSpec.describe Procedures::Destroy, type: :operation do
  describe ".result" do
    context "when procedure can be destroyed" do
      let!(:procedure) { create(:procedure) }

      it "is successful" do
        expect(described_class.result(id: procedure.id.to_s)).to be_success
      end

      it "destroys procedure" do
        expect { described_class.result(id: procedure.id.to_s) }.to change(Procedure, :count).by(-1)
      end
    end

    context "when procedure cannot be destroyed" do
      let!(:procedure) { create(:procedure) }

      it "is failure" do
        allow(Procedure).to receive(:find).with(procedure.id.to_s).and_return(procedure)
        allow(procedure).to receive(:destroy).and_return(false)

        expect(described_class.result(id: procedure.id.to_s)).to be_failure
      end

      it "does not destroy procedure" do
        allow(Procedure).to receive(:find).with(procedure.id.to_s).and_return(procedure)
        allow(procedure).to receive(:destroy).and_return(false)

        expect { described_class.result(id: procedure.id.to_s) }.not_to change(Procedure, :count)
      end

      it "returns error message" do
        allow(Procedure).to receive(:find).with(procedure.id.to_s).and_return(procedure)
        allow(procedure).to receive(:destroy).and_return(false)

        result = described_class.result(id: procedure.id.to_s)

        expect(result.error).to eq(:cannot_destroy)
      end
    end

    context "when procedure with given id doesn't exist" do
      it "raises ActiveRecord::RecordNotFound error" do
        expect { described_class.result(id: "nonexistent") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
