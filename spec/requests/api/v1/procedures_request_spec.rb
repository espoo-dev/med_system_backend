# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Procedures" do
  describe "GET /api/v1/procedures" do
    context "when user is not authenticated" do
      let(:do_request) { get "/api/v1/procedures" }

      it "returns unauthorized" do
        get "/api/v1/procedures"

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        get "/api/v1/procedures"

        expect(response.parsed_body["error"]).to eq("You need to sign in or sign up before continuing.")
      end
    end

    context "when user is authenticated" do
      let!(:user) { create(:user) }

      before do
        create_list(:procedure, 5)
        sign_in user
        get("/api/v1/procedures", params: {})
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
      let(:do_request) { get "/api/v1/procedures", params: }
      let(:json_response) { response.parsed_body }
      let(:params) do
        {
          page: 2,
          per_page: 5
        }
      end

      before do
        create_list(:procedure, 8)
        sign_in user
        do_request
      end

      it "returns only 3 procedures" do
        expect(json_response.length).to eq(3)
      end
    end
  end
end
