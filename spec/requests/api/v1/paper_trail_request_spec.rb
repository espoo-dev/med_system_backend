# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PaperTrail::Version", versioning: true do
  let(:hospital) { create(:hospital, name: "nome hospital", address: "Barbalha- CE") }

  context "when api request" do
    let(:hospitals) { Hospital.all }
    let(:hospital_created) { hospitals.last }
    let(:user) { create(:user) }

    describe "POST /api/v1/hospitals" do
      before do
        post "/api/v1/hospitals", params: { name: "Hospital", address: "Address" },
          headers: auth_token_for(user)
      end

      context "when create hospital" do
        it { expect(response).to have_http_status(:created) }
        it { expect(hospitals.count).to eq(1) }
        it { expect(hospital_created.versions.count).to eq(1) }
      end
    end

    describe "PUT /api/v1/hospitals/:id" do
      let(:hospital_version) { hospital.reload.versions }
      let(:last_hospital_version) { hospital_version.last }

      before do
        put "/api/v1/hospitals/#{hospital.id}", params: { name: "Hospital", address: "Address" },
          headers: auth_token_for(user)
      end

      context "when update hospital and create version" do
        it { expect(response).to have_http_status(:ok) }
        it { expect(hospital_version.count).to eq(2) }
        it { expect(last_hospital_version.object["name"]).to eq("nome hospital") }
        it { expect(last_hospital_version["whodunnit"]).to eq(user.id.to_s) }
      end
    end
  end
end
