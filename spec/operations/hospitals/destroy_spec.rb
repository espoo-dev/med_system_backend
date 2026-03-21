# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hospitals::Destroy, type: :operation do
  describe ".result" do
    context "when hospital can be destroyed" do
      let!(:hospital) { create(:hospital) }

      it "is successful" do
        expect(described_class.result(id: hospital.id.to_s)).to be_success
      end

      it "destroys hospital" do
        expect { described_class.result(id: hospital.id.to_s) }.to change(Hospital, :count).by(-1)
      end
    end

    context "when hospital cannot be destroyed" do
      let!(:hospital) { create(:hospital) }

      before do
        allow_any_instance_of(Hospital).to receive(:destroy).and_return(false) # rubocop:disable RSpec/AnyInstance
      end

      it "is failure" do
        expect(described_class.result(id: hospital.id.to_s)).to be_failure
      end

      it "does not destroy hospital" do
        expect { described_class.result(id: hospital.id.to_s) }.not_to change(Hospital, :count)
      end

      it "returns error cannot_destroy" do
        expect(described_class.result(id: hospital.id.to_s).error).to eq(:cannot_destroy)
      end
    end

    context "when hospital is outside the given scope" do
      let!(:hospital) { create(:hospital) }
      let(:empty_scope) { Hospital.none }

      it "raises ActiveRecord::RecordNotFound" do
        expect do
          described_class.result(id: hospital.id.to_s, scope: empty_scope)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when hospital with given id does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { described_class.result(id: "non-existent-id") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
