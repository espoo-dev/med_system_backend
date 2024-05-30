# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaperTrail::Version, versioning: true do
  let(:hospital) { create(:hospital, name: "nome hospital", address: "Barbalha- CE") }

  context "when persist object in database" do
    it "creates version" do
      expect(hospital).to be_persisted
      expect(hospital.versions.count).to eq(1)
    end
  end

  context "when update object in database" do
    let(:update_hospital) { hospital.update!(name: "Hospital") }
    let(:hospital_version) { hospital.versions }
    let(:last_hospital_version) { hospital_version.last }

    before { update_hospital }

    it { expect(hospital_version.count).to eq(2) }
    it { expect(last_hospital_version.object["name"]).to eq("nome hospital") }
    it { expect(last_hospital_version.object["whodunnit"]).to be_nil }
  end
end
