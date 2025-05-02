# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Procedures" do
  let!(:user) { create(:user) }
  let(:headers) { auth_token_for(user) }

  describe "GET /api/v1/procedures" do
    let(:path) { "/api/v1/procedures" }
    let(:http_method) { :get }
    let(:params) { {} }

    context "when user is authenticated" do
      before do
        create_list(:procedure, 5)

        get(path, params: {}, headers: headers)
      end

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end

      it "returns all procedures" do
        expect(response.parsed_body.length).to eq(5)
      end
    end

    context "when has pagination via page and per_page" do
      before do
        create_list(:procedure, 8)

        get path, params: { page: 2, per_page: 5 }, headers: headers
      end

      it "returns only 3 procedures" do
        expect(response.parsed_body.length).to eq(3)
      end
    end

    include_context "when user is not authenticated"
  end

  describe "POST /api/v1/procedures" do
    let(:path) { "/api/v1/procedures" }
    let(:http_method) { :post }
    let(:headers) { auth_token_for(user) }
    let(:params) { {} }

    context "when user is authenticated" do
      context "with valid params" do
        let(:attributes) do
          { name: "Test Procedure", code: "03.02.04.01-5", amount_cents: 1000 }
        end

        it "returns created" do
          post path, params: attributes, headers: headers

          expect(response).to have_http_status(:created)
        end
      end

      context "with invalid params" do
        let(:invalid_attributes) { { name: nil, code: nil } }

        it "returns unprocessable_entity" do
          post path, params: invalid_attributes, headers: headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns error messages" do
          post path, params: invalid_attributes, headers: headers

          expect(response.parsed_body.symbolize_keys).to include(
            name: ["can't be blank"],
            code: ["can't be blank"]
          )
        end
      end
    end

    include_context "when user is not authenticated"
  end

  describe "PUT /api/v1/procedures/:id" do
    let(:procedure) { create(:procedure, user: user) }
    let(:http_method) { :put }
    let(:params) { { name: "New Procedure Name", amount_cents: 1000 } }
    let(:path) { "/api/v1/procedures/#{procedure.id}" }

    context "when user is authenticated" do
      context "with valid attributes" do
        it "returns ok" do
          put path, params: params, headers: headers

          expect(response).to have_http_status(:ok)
        end
      end

      context "with invalid attributes" do
        it "returns unprocessable_content" do
          put path, params: { name: nil }, headers: headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns error messages" do
          put path, params: { name: nil }, headers: headers

          expect(response.parsed_body.symbolize_keys).to include(
            name: ["can't be blank"]
          )
        end
      end
    end

    include_context "when user is not authenticated"
  end

  describe "DELETE /api/v1/procedures/:id" do
    let(:procedure) { create(:procedure, user: user) }
    let(:http_method) { :delete }
    let(:path) { "/api/v1/procedures/#{procedure.id}" }
    let(:params) { {} }
    let(:model_class) { Procedure }

    context "when user is authenticated" do
      include_examples "delete request returns ok"

      context "when procedure cannot be destroyed" do
        it "returns unprocessable_content" do
          allow(Procedure).to receive(:find).with(procedure.id.to_s).and_return(procedure)
          allow(procedure).to receive(:destroy).and_return(false)

          delete path, headers: headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns error messages" do
          allow(Procedure).to receive(:find).with(procedure.id.to_s).and_return(procedure)
          allow(procedure).to receive(:destroy).and_return(false)

          delete path, headers: headers

          expect(response.parsed_body).to eq("cannot_destroy")
        end
      end
    end

    include_context "when user is not authenticated"
  end
end
