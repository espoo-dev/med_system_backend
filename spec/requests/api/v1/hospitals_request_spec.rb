# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Hospitals" do
  describe "GET /api/v1/hospitals" do
    context "when user is not authenticated" do
      it "retuns unauthorized status" do
        get "/api/v1/hospitals"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      context "when there are hospitals" do
        let!(:hospitals) { create_list(:hospital, 2) }

        before do
          headers = auth_token_for(create(:user))
          get "/api/v1/hospitals", headers: headers
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns hospitals" do
          expect(response.parsed_body).to include(
            {
              "id" => hospitals.first.id,
              "name" => hospitals.first.name,
              "address" => hospitals.first.address
            },
            {
              "id" => hospitals.second.id,
              "name" => hospitals.second.name,
              "address" => hospitals.second.address
            }
          )
        end
      end

      context "when there are no hospitals" do
        before do
          headers = auth_token_for(create(:user))
          get "/api/v1/hospitals", headers: headers
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns empty array" do
          expect(response.parsed_body).to eq([])
        end
      end

      context "when has pagination via page and per_page" do
        before do
          create_list(:hospital, 8)
          headers = auth_token_for(create(:user))
          get "/api/v1/hospitals", params: { page: 2, per_page: 5 }, headers: headers
        end

        it "returns only 3 hospitals" do
          expect(response.parsed_body.length).to eq(3)
        end
      end
    end
  end

  describe "POST /api/v1/hospitals" do
    context "when user is not authenticated" do
      it "retuns unauthorized status" do
        post "/api/v1/hospitals", params: { name: "Hospital", address: "Address" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      context "when params are valid" do
        before do
          headers = auth_token_for(create(:user))
          post "/api/v1/hospitals", params: { name: "Hospital", address: "Address" }, headers: headers
        end

        it "returns created" do
          expect(response).to have_http_status(:created)
        end

        it "returns hospital" do
          expect(response.parsed_body).to include(
            "id" => Hospital.last.id,
            "name" => "Hospital",
            "address" => "Address"
          )
        end
      end

      context "when params are invalid" do
        before do
          headers = auth_token_for(create(:user))
          post "/api/v1/hospitals", params: { name: nil, address: nil }, headers: headers
        end

        it "returns unprocessable_content" do
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns errors" do
          expect(response.parsed_body).to eq(
            "name" => ["can't be blank"],
            "address" => ["can't be blank"]
          )
        end
      end
    end
  end

  describe "PUT /api/v1/hospitals/:id" do
    context "when user is not authenticated" do
      it "retuns unauthorized status" do
        hospital = create(:hospital)
        put "/api/v1/hospitals/#{hospital.id}", params: { name: "Hospital", address: "Address" }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      context "when params are valid" do
        let!(:hospital) { create(:hospital, name: "Old Name") }

        before do
          headers = auth_token_for(create(:user))
          put "/api/v1/hospitals/#{hospital.id}", params: { name: "New Name" }, headers: headers
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns hospital" do
          expect(response.parsed_body.symbolize_keys).to include(
            id: hospital.id,
            name: "New Name"
          )
        end
      end

      context "when params are invalid" do
        let!(:hospital) { create(:hospital, name: "Old Name") }

        before do
          headers = auth_token_for(create(:user))
          put "/api/v1/hospitals/#{hospital.id}", params: { name: nil, address: nil }, headers: headers
        end

        it "returns unprocessable_content" do
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns errors" do
          expect(response.parsed_body).to eq(
            "name" => ["can't be blank"],
            "address" => ["can't be blank"]
          )
        end
      end
    end
  end

  describe "DELETE /api/v1/hospitals/:id" do
    context "when user is not authenticated" do
      it "retuns unauthorized status" do
        hospital = create(:hospital)

        delete "/api/v1/hospitals/#{hospital.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      it "returns ok" do
        hospital = create(:hospital)
        headers = auth_token_for(create(:user))

        delete "/api/v1/hospitals/#{hospital.id}", headers: headers

        expect(response).to have_http_status(:ok)
      end

      context "when hospital cannot be destroyed" do
        it "returns unprocessable_content" do
          hospital = create(:hospital)
          headers = auth_token_for(create(:user))
          allow(Hospital).to receive(:find).with(hospital.id.to_s).and_return(hospital)
          allow(hospital).to receive(:destroy).and_return(false)

          delete "/api/v1/hospitals/#{hospital.id}", headers: headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns errors" do
          hospital = create(:hospital)
          headers = auth_token_for(create(:user))
          allow(Hospital).to receive(:find).with(hospital.id.to_s).and_return(hospital)
          allow(hospital).to receive(:destroy).and_return(false)

          delete "/api/v1/hospitals/#{hospital.id}", headers: headers

          expect(response.parsed_body).to eq("cannot_destroy")
        end
      end
    end
  end
end
