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

      it "is failure" do
        allow(Hospital).to receive(:find).with(hospital.id.to_s).and_return(hospital)
        allow(hospital).to receive(:destroy).and_return(false)

        expect(described_class.result(id: hospital.id.to_s)).to be_failure
      end

      it "does not destroy hospital" do
        allow(Hospital).to receive(:find).with(hospital.id.to_s).and_return(hospital)
        allow(hospital).to receive(:destroy).and_return(false)

        expect { described_class.result(id: hospital.id.to_s) }.not_to change(Hospital, :count)
      end

      it "returns error cannot_destroy" do
        allow(Hospital).to receive(:find).with(hospital.id.to_s).and_return(hospital)
        allow(hospital).to receive(:destroy).and_return(false)

        expect(described_class.result(id: hospital.id.to_s).error).to eq(:cannot_destroy)
      end
    end

    context "when hospital with given id does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect { described_class.result(id: "non-existent-id") }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
