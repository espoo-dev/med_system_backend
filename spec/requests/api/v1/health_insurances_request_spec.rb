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
          params = { custom: false }
          get "/api/v1/health_insurances", headers: headers, params: params
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns health_insurances" do
          expect(response.parsed_body).to include(
            {
              "id" => health_insurances.first.id,
              "name" => health_insurances.first.name,
              "custom" => false,
              "user_id" => nil
            },
            {
              "id" => health_insurances.second.id,
              "name" => health_insurances.second.name,
              "custom" => false,
              "user_id" => nil
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
          get "/api/v1/health_insurances", params: { page: 2, per_page: 5, custom: false }, headers: headers
        end

        it "returns only 3 health_insurances" do
          expect(response.parsed_body.length).to eq(3)
        end
      end
    end
  end

  describe "POST /api/v1/health_insurances" do
    context "when user is not authenticated" do
      it "returns unauthorized status" do
        post "/api/v1/health_insurances"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      context "when params are valid" do
        let(:health_insurance_params) { attributes_for(:health_insurance) }

        before do
          headers = auth_token_for(create(:user))
          post "/api/v1/health_insurances", params: health_insurance_params, headers: headers
        end

        it "returns created" do
          expect(response).to have_http_status(:created)
        end

        it "returns health_insurance" do
          expect(response.parsed_body).to include(
            "id" => HealthInsurance.last.id,
            "name" => health_insurance_params[:name]
          )
        end
      end

      context "when params are invalid" do
        let(:health_insurance_params) { { name: nil } }

        before do
          headers = auth_token_for(create(:user))
          post "/api/v1/health_insurances", params: health_insurance_params, headers: headers
        end

        it "returns unprocessable_content" do
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns errors" do
          expect(response.parsed_body).to include("name" => ["can't be blank"])
        end
      end
    end
  end
end
