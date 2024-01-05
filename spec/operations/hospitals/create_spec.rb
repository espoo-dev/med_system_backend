# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hospitals::Create, type: :operation do
  describe ".result" do
    context "with valid attributes" do
      let(:valid_attributes) { attributes_for(:hospital) }

      it "is successful" do
        result = described_class.result(attributes: valid_attributes)

        expect(result).to be_success
      end

      it "creates a hospital" do
        expect do
          described_class.result(attributes: valid_attributes)
        end.to change(Hospital, :count).by(1)
      end
    end

    context "with invalid attributes" do
      let(:invalid_attributes) { attributes_for(:hospital, name: nil) }

      it "is failure" do
        result = described_class.result(attributes: invalid_attributes)

        expect(result).to be_failure
      end

      it "does not create a hospital" do
        result = described_class.result(attributes: invalid_attributes)

        expect(result.hospital).not_to be_persisted
      end
    end
  end
end
