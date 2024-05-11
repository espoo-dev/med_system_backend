# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaperTrail::Version, versioning: true do
  let(:hospital) { create(:hospital, name: "nome hospital", address: "Barbalha- CE") }

  context "when persist object in database" do
    it "does not create version" do
      expect(hospital).to be_persisted
      expect(hospital.versions.count).to eq(0)
    end
  end

  context "when update object in database" do
    let(:update_hospital) { hospital.update!(name: "Hospital") }
    let(:hospital_version) { hospital.versions }
    let(:last_hospital_version) { hospital_version.last }

    before { update_hospital }

    it { expect(hospital_version.count).to eq(1) }
    it { expect(last_hospital_version.object["name"]).to eq("nome hospital") }
  end

  context "when api request", type: :request do
    let(:hospital_creation) { Hospital.all }
    let(:hospital_created) { hospital_creation.last }

    describe "POST /api/v1/hospitals" do
      before do
        post "/api/v1/hospitals", params: { name: "Hospital", address: "Address" },
          headers: auth_token_for(create(:user))
      end

      it "creates hospital and not version" do
        expect(response).to have_http_status(:created)
        expect(hospital_creation.count).to eq(1)
        expect(hospital_created.versions.count).to eq(0)
      end
    end

    describe "PUT /api/v1/hospitals/:id" do
      let(:hospital) { create(:hospital, name: "Hospital first") }
      let(:hospital_version) { hospital.versions }
      let(:last_hospital_version) { hospital_version.last }

      before do
        put "/api/v1/hospitals/#{hospital.id}", params: { name: "Hospital", address: "Address" },
          headers: auth_token_for(create(:user))
      end

      it "creates hospital and version" do
        expect(response).to have_http_status(:ok)
        expect(hospital_version.count).to eq(1)
        expect(last_hospital_version.object["name"]).to eq("Hospital first")
      end
    end
  end
end
