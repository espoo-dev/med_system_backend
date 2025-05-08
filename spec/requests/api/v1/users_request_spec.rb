# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users" do
  describe "GET /api/v1/users" do
    let(:token) { api_token(user) }
    let(:path) { "/api/v1/users" }
    let(:headers) { auth_token_for(user) }

    context "when user authenticated" do
      context "when user is authorized" do
        let!(:user) { create(:user, admin: true) }

        context "when data is valid" do
          before do
            get "/api/v1/users", params: {}, headers: headers
          end

          it { expect(response.parsed_body.first).to have_key("id") }
          it { expect(response.parsed_body.first).to have_key("email") }
          it { expect(response.parsed_body.first["email"]).to eq(user.email) }
          it { expect(response).to have_http_status(:ok) }
        end

        context "when has pagination via page and per_page" do
          params = { page: 2, per_page: 5 }

          before do
            create_list(:user, 8)
            headers = auth_token_for(user)
            get "/api/v1/users", params: params, headers: headers
          end

          it "returns only 4 users" do
            expect(response.parsed_body.length).to eq(4)
          end
        end
      end

      context "when user is unauthorized" do
        let(:user) { create(:user) }

        before do
          get path, params: {}, headers: headers
        end

        it { expect(response).to have_http_status(:unauthorized) }

        it {
          expect(response.parsed_body["error"]).to eq("not allowed to index? this User::ActiveRecord_Relation")
        }
      end
    end

    context "when user unauthenticated" do
      context "when has user" do
        before do
          get path
        end

        it { expect(response).to have_http_status(:unauthorized) }

        it {
          expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
        }
      end
    end

    context "when token is expired" do
      let(:user) { create(:user, admin: true) }

      it "returns unauthorized for token expiration" do
        get "/api/v1/users", headers: headers
        expect(response).to have_http_status(:ok)

        travel 40.minutes

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
      end
    end
  end

  describe "Password recovery" do
    subject(:get_new_password) { get "/users/password/new" }

    let(:user) { create(:user, email: "email@email.com") }
    let(:headers) { auth_token_for(user) }

    it "returns ok" do
      get_new_password
      expect(response).to have_http_status(:ok)
    end

    it "contains reset token" do
      get_new_password
      token = response.parsed_body.css('input[name="authenticity_token"]').first["value"]
      expect(token).not_to be_nil
    end

    it "sends reset instructions" do
      get_new_password

      auth_token = response.parsed_body.css('input[name="authenticity_token"]').first["value"]

      post "/users/password",
        headers: headers,
        params: {
          authenticity_token: auth_token,
          user: { email: user.email }
        }

      expect { user.reload }.to change(user, :reset_password_token)
    end
  end
end
