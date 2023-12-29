# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Procedures" do
  describe "GET /api/v1/procedures" do
    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/api/v1/procedures", params: {}, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        get "/api/v1/procedures"

        expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
      end
    end

    context "when user is authenticated" do
      let!(:user) { create(:user) }

      before do
        create_list(:procedure, 5)
        headers = auth_token_for(user)
        get("/api/v1/procedures", params: {}, headers: headers)
      end

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end

      it "returns all procedures" do
        expect(response.parsed_body.length).to eq(5)
      end
    end

    context "when has pagination via page and per_page" do
      let!(:user) { create(:user) }

      before do
        create_list(:procedure, 8)
        headers = auth_token_for(user)
        get "/api/v1/procedures", params: { page: 2, per_page: 5 }, headers: headers
      end

      it "returns only 3 procedures" do
        expect(response.parsed_body.length).to eq(3)
      end
    end
  end

  describe "POST /api/v1/procedures" do
    context "when user is not authenticated" do
      it "returns unauthorized" do
        post "/api/v1/procedures", params: {}, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        post "/api/v1/procedures"

        expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
      end
    end

    context "when user is authenticated" do
      context "with valid params" do
        let!(:user) { create(:user) }
        let(:headers) { auth_token_for(user) }
        let(:attributes) do
          { name: "Test Procedure", code: "03.02.04.01-5", amount_cents: 1000 }
        end

        it "returns created" do
          post "/api/v1/procedures", params: attributes, headers: headers

          expect(response).to have_http_status(:created)
        end
      end

      context "with invalid params" do
        let!(:user) { create(:user) }
        let(:headers) { auth_token_for(user) }
        let(:invalid_attributes) { { name: nil, code: nil } }

        it "returns unprocessable_entity" do
          post "/api/v1/procedures", params: invalid_attributes, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns error messages" do
          post "/api/v1/procedures", params: invalid_attributes, headers: headers

          expect(response.parsed_body.symbolize_keys).to include(
            name: ["can't be blank"],
            code: ["can't be blank"]
          )
        end
      end
    end
  end

  describe "PUT /api/v1/procedures/:id" do
    context "when user is authenticated" do
      context "with valid attributes" do
        it "returns ok" do
          procedure = create(:procedure)

          params = { name: "New Procedure Name", amount_cents: 1000 }

          headers = auth_token_for(create(:user))
          put "/api/v1/procedures/#{procedure.id}", params: params, headers: headers

          expect(response).to have_http_status(:ok)
        end
      end

      context "with invalid attributes" do
        it "returns unprocessable_entity" do
          procedure = create(:procedure)

          headers = auth_token_for(create(:user))
          put "/api/v1/procedures/#{procedure.id}", params: { name: nil }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        procedure = create(:procedure)

        params = { name: "New Procedure Name", amount_cents: 1000 }

        put "/api/v1/procedures/#{procedure.id}", params: params, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/procedures/:id" do
    context "when user is authenticated" do
      it "returns ok" do
        procedure = create(:procedure)

        headers = auth_token_for(create(:user))
        delete "/api/v1/procedures/#{procedure.id}", headers: headers

        expect(response).to have_http_status(:ok)
      end

      context "when procedure cannot be destroyed" do
        it "returns unprocessable_entity" do
          procedure = create(:procedure)

          allow(Procedure).to receive(:find).with(procedure.id.to_s).and_return(procedure)
          allow(procedure).to receive(:destroy).and_return(false)

          headers = auth_token_for(create(:user))
          delete "/api/v1/procedures/#{procedure.id}", headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        procedure = create(:procedure)

        delete "/api/v1/procedures/#{procedure.id}", headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
