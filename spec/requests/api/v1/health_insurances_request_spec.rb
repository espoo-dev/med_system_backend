# frozen_string_literal: true

require "rails_helper"

RSpec.describe "HealthInsurances" do
  let!(:user) { create(:user) }
  let(:headers) { auth_token_for(user) }

  describe "GET /api/v1/health_insurances" do
    let(:path) { "/api/v1/health_insurances" }
    let(:http_method) { :get }
    let(:params) { {} }

    context "when user is authenticated" do
      context "when there are health insurances" do
        let!(:health_insurances) { create_list(:health_insurance, 2) }

        before do
          params = { custom: false }
          get path, headers: headers, params: params
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

      context "when Custom param is true" do
        let!(:health_insurance_custom) { create(:health_insurance, custom: true, user: user) }
        let(:health_insurance_not_custom) { create(:health_insurance, custom: false, user: user) }
        let(:health_insurance_default) { create(:health_insurance, custom: false, user: nil) }

        before do
          params = { custom: true }
          get "/api/v1/health_insurances", headers: headers, params: params
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns health_insurances" do
          expect(response.parsed_body[0]).to eq(
            {
              "id" => health_insurance_custom.id,
              "name" => health_insurance_custom.name,
              "custom" => true,
              "user_id" => user.id
            }
          )
        end
      end

      context "when Custom param is false" do
        let(:health_insurance_custom) { create(:health_insurance, custom: true, user: user) }
        let!(:health_insurance_not_custom) { create(:health_insurance, custom: false, user: user) }
        let!(:health_insurance_default) { create(:health_insurance, custom: false, user: nil) }

        before do
          params = { custom: false }
          get "/api/v1/health_insurances", headers: headers, params: params
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns health_insurances" do
          expect(response.parsed_body).to include(
            {
              "id" => health_insurance_not_custom.id,
              "name" => health_insurance_not_custom.name,
              "custom" => false,
              "user_id" => user.id
            },
            {
              "id" => health_insurance_default.id,
              "name" => health_insurance_default.name,
              "custom" => false,
              "user_id" => nil
            }
          )
        end
      end

      context "when Custom param is missing" do
        let!(:health_insurance_custom) { create(:health_insurance, custom: true, user: user) }
        let!(:health_insurance_not_custom) { create(:health_insurance, custom: false, user: user) }
        let!(:health_insurance_default) { create(:health_insurance, custom: false, user: nil) }

        before do
          params = {}
          get path, headers: headers, params: params
        end

        it "returns ok" do
          expect(response).to have_http_status(:ok)
        end

        it "returns health_insurances" do
          expect(response.parsed_body).to include(
            {
              "id" => health_insurance_custom.id,
              "name" => health_insurance_custom.name,
              "custom" => true,
              "user_id" => user.id
            },
            {
              "id" => health_insurance_not_custom.id,
              "name" => health_insurance_not_custom.name,
              "custom" => false,
              "user_id" => user.id
            },
            {
              "id" => health_insurance_default.id,
              "name" => health_insurance_default.name,
              "custom" => false,
              "user_id" => nil
            }
          )
        end
      end

      context "when there are no health insurances" do
        before do
          get path, headers: headers
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
          get path, params: { page: 2, per_page: 5, custom: false }, headers: headers
        end

        it "returns only 3 health_insurances" do
          expect(response.parsed_body.length).to eq(3)
        end
      end
    end

    include_context "when user is not authenticated"
  end

  describe "POST /api/v1/health_insurances" do
    let(:path) { "/api/v1/health_insurances" }
    let(:http_method) { :post }
    let(:params) { {} }

    include_context "when user is not authenticated"

    context "when user is authenticated" do
      context "when params are valid" do
        let(:health_insurance_params) { attributes_for(:health_insurance) }

        before do
          post path, params: health_insurance_params, headers: headers
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
