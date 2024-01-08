# frozen_string_literal: true

require "rails_helper"

RSpec.describe "HealthInsurances" do
  describe "GET /api/v1/health_insurances" do
    context "when user is not authenticated" do
      it "returns unauthorized status" do
        get "/api/v1/health_insurances"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      context "when there are health insurances" do
        let!(:health_insurances) { create_list(:health_insurance, 2) }

        before do
          headers = auth_token_for(create(:user))
          get "/api/v1/health_insurances", headers: headers
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns health_insurances" do
          expect(response.parsed_body).to include(
            {
              "id" => health_insurances.first.id,
              "name" => health_insurances.first.name
            },
            {
              "id" => health_insurances.second.id,
              "name" => health_insurances.second.name
            }
          )
        end
      end

      context "when there are no health insurances" do
        before do
          headers = auth_token_for(create(:user))
          get "/api/v1/health_insurances", headers: headers
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
          create_list(:health_insurance, 8)
          headers = auth_token_for(create(:user))
          get "/api/v1/health_insurances", params: { page: 2, per_page: 5 }, headers: headers
        end

        it "returns only 3 health_insurances" do
          expect(response.parsed_body.length).to eq(3)
        end
      end
    end
  end
end
