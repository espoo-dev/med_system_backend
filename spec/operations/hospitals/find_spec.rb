# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hospitals::Find, type: :operation do
  describe ".result" do
    context "when hospital with given id exists" do
      it "is successful" do
        hospital = create(:hospital)
        result = described_class.result(id: hospital.id.to_s)

        expect(result).to be_success
      end

      it "returns hospital" do
        hospital = create(:hospital)
        result = described_class.result(id: hospital.id.to_s)

        expect(result.hospital).to eq(hospital)
      end
    end

    context "when hospital with given id does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect do
          described_class.result(id: "non-existing-id")
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when using a scope" do
      let!(:hospital) { create(:hospital, name: "Hospital A", address: "Address A") }
      let!(:other_hospital) { create(:hospital, name: "Hospital B", address: "Address B") }

      it "returns found hospital when it exists in scope" do
        result = described_class.result(
          id: hospital.id.to_s,
          scope: Hospital.where(name: "Hospital A")
        )

        expect(result.hospital).to eq(hospital)
      end

      it "raises ActiveRecord::RecordNotFound when record exists but not in scope" do
        expect do
          described_class.result(
            id: other_hospital.id.to_s,
            scope: Hospital.where(name: "Hospital A")
          )
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
