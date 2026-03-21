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

      before do
        allow_any_instance_of(EventProcedure).to receive(:destroy).and_return(false) # rubocop:disable RSpec/AnyInstance
      end

      it "is failure" do
        expect(described_class.result(id: event_procedure.id.to_s)).to be_failure
      end

      it "does not destroy event_procedure" do
        expect { described_class.result(id: event_procedure.id.to_s) }.not_to change(EventProcedure, :count)
      end

      it "returns error message" do
        expect(described_class.result(id: event_procedure.id.to_s).error).to eq(:cannot_destroy)
      end
    end

    context "when event_procedure is outside the given scope" do
      let!(:event_procedure) { create(:event_procedure) }
      let(:empty_scope) { EventProcedure.none }

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          described_class.result(id: event_procedure.id.to_s, scope: empty_scope)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when event_procedure with given id doesn't exist" do
      it "raises ActiveRecord::RecordNotFound error" do
        expect { described_class.result(id: "nonexistent") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
