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
end
