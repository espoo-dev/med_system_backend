# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hospital do
  describe "soft delete behavior" do
    let(:hospital) { create(:hospital) }

    it_behaves_like "acts as paranoid", :hospital
  end

  describe "associations" do
    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }

    context "when validating name uniqueness" do
      it "does not allow duplicate names" do
        create(:hospital, name: "nome hospital", address: "Barbalha- CE")
        new_hospital = build(:hospital, name: "nomE hospitAl", address: "Barbalha- Ce")

        expect(new_hospital).not_to be_valid
        expect(new_hospital.errors.full_messages).to eq(["Name has already been taken"])
      end
    end
  end
end
