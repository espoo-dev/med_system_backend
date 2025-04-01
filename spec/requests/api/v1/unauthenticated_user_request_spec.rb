# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Unauthenticated Access" do
  describe "GET /api/v1/patients" do
    let(:routes_path) { "/api/v1/patients" }

    include_context "when user is not authenticated"

    it "returns unauthorized" do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
