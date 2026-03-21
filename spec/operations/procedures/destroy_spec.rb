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

      before do
        allow_any_instance_of(Procedure).to receive(:destroy).and_return(false) # rubocop:disable RSpec/AnyInstance
      end

      it "is failure" do
        expect(described_class.result(id: procedure.id.to_s)).to be_failure
      end

      it "does not destroy procedure" do
        expect { described_class.result(id: procedure.id.to_s) }.not_to change(Procedure, :count)
      end

      it "returns error message" do
        expect(described_class.result(id: procedure.id.to_s).error).to eq(:cannot_destroy)
      end
    end

    context "when procedure is outside the given scope" do
      let!(:procedure) { create(:procedure) }
      let(:empty_scope) { Procedure.none }

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          described_class.result(id: procedure.id.to_s, scope: empty_scope)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when procedure with given id doesn't exist" do
      it "raises ActiveRecord::RecordNotFound error" do
        expect { described_class.result(id: "nonexistent") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
