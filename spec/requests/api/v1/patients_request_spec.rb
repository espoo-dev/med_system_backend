# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Patients" do
  describe "GET ap1/v1/patients" do
    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/api/v1/patients"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      context "when there are patients" do
        let!(:patients) { create_list(:patient, 2, user:) }
        let(:user) { create(:user) }

        before do
          headers = auth_token_for(user)
          get "/api/v1/patients", headers:
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns patients" do
          expect(response.parsed_body).to include(
            {
              "id" => patients.first.id,
              "name" => patients.first.name
            },
            {
              "id" => patients.second.id,
              "name" => patients.second.name
            }
          )
        end
      end

      context "when there are no patients" do
        before do
          headers = auth_token_for(create(:user))
          get "/api/v1/patients", headers: headers
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns empty array" do
          expect(response.parsed_body).to eq([])
        end
      end

      context "when has pagination via page and per_page" do
        let(:user) { create(:user) }

        before do
          create_list(:patient, 8, user:)
          headers = auth_token_for(user)
          get "/api/v1/patients", params: { page: 2, per_page: 5 }, headers: headers
        end

        it "returns only 3 patients" do
          expect(response.parsed_body.length).to eq(3)
        end
      end
    end
  end

  describe "POST api/v1/patients" do
    context "when user is not authenticated" do
      let(:attributes) { { name: "John" } }

      before do
        post "/api/v1/patients", params: attributes
      end

      it "returns unauthorized" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      context "when params are valid" do
        let(:attributes) { { name: "John" } }
        let(:user) { create(:user) }

        before do
          headers = auth_token_for(user)
          post "/api/v1/patients", params: attributes, headers:
        end

        it "returns created" do
          expect(response).to have_http_status(:created)
        end

        it "returns patient" do
          expect(response.parsed_body.symbolize_keys).to include(
            id: be_present,
            name: attributes[:name]
          )
        end
      end

      context "when params are invalid" do
        let(:invalid_attributes) { { name: nil } }

        before do
          headers = auth_token_for(create(:user))
          post "/api/v1/patients", params: invalid_attributes, headers: headers
        end

        it "returns unprocessable_entity" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns errors" do
          expect(response.parsed_body.symbolize_keys).to include(
            name: ["can't be blank"]
          )
        end
      end
    end
  end

  describe "PUT api/v1/patients/:id" do
    context "when user is not authenticated" do
      let!(:patient) { create(:patient) }

      it "returns unauthorized" do
        put "/api/v1/patients/#{patient.id}", params: { name: "John" }, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      context "when params are valid" do
        let!(:patient) { create(:patient, name: "Old Name") }

        before do
          headers = auth_token_for(create(:user))
          put "/api/v1/patients/#{patient.id}", params: { name: "New Name" }, headers: headers
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns patient" do
          expect(response.parsed_body.symbolize_keys).to include(
            id: patient.id,
            name: "New Name"
          )
        end
      end

      context "when params are invalid" do
        let!(:patient) { create(:patient) }

        before do
          headers = auth_token_for(create(:user))
          put "/api/v1/patients/#{patient.id}", params: { name: nil }, headers: headers
        end

        it "returns unprocessable_entity" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns errors" do
          expect(response.parsed_body.symbolize_keys).to include(
            name: ["can't be blank"]
          )
        end
      end
    end
  end

  describe "DELETE api/v1/patients/:id" do
    context "when user is not authenticated" do
      let!(:patient) { create(:patient) }

      it "returns unauthorized" do
        delete "/api/v1/patients/#{patient.id}", headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      it "returns ok" do
        patient = create(:patient)
        headers = auth_token_for(create(:user))

        delete "/api/v1/patients/#{patient.id}", headers: headers

        expect(response).to have_http_status(:ok)
      end

      context "when patient cannot be destroyed" do
        it "returns unprocessable_entity" do
          patient = create(:patient)
          headers = auth_token_for(create(:user))
          allow(Patient).to receive(:find).with(patient.id.to_s).and_return(patient)
          allow(patient).to receive(:destroy).and_return(false)

          delete "/api/v1/patients/#{patient.id}", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns errors" do
          patient = create(:patient)
          headers = auth_token_for(create(:user))
          allow(Patient).to receive(:find).with(patient.id.to_s).and_return(patient)
          allow(patient).to receive(:destroy).and_return(false)

          delete "/api/v1/patients/#{patient.id}", headers: headers

          expect(response.parsed_body).to eq("cannot_destroy")
        end
      end
    end
  end
end
