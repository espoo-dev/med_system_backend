# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EventProcedures" do
  describe "GET /api/v1/event_procedures" do
    context "when user is not authenticated" do
      it "returns unauthorized" do
        get "/api/v1/event_procedures", params: {}, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        get "/api/v1/event_procedures"

        expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
      end
    end

    context "when user is authenticated" do
      let!(:user) { create(:user) }

      before do
        create_list(:event_procedure, 5)
        headers = auth_token_for(user)
        get("/api/v1/event_procedures", params: {}, headers: headers)
      end

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end

      it "returns all event_procedures" do
        expect(response.parsed_body.length).to eq(5)
      end
    end

    context "when has pagination via page and per_page" do
      let!(:user) { create(:user) }

      before do
        create_list(:event_procedure, 8)
        headers = auth_token_for(user)
        get "/api/v1/event_procedures", params: { page: 2, per_page: 5 }, headers: headers
      end

      it "returns only 3 event_procedures" do
        expect(response.parsed_body.length).to eq(3)
      end
    end
  end
end
