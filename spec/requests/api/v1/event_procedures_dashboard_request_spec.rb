# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EventProcedures" do
  describe "GET /api/v1/event_procedures_dashboard/amount_by_day" do
    let(:do_request) { get "/api/v1/event_procedures_dashboard/amount_by_day", params:, headers: }
    let(:params) { { start_date: "01/06/2000", end_date: "05/06/2000" } }

    describe "authentication" do
      context "when user is not authenticated" do
        let(:params) { {} }
        let(:headers) { {} }

        it "returns unauthorized" do
          do_request
          expect(response).to have_http_status(:unauthorized)
        end

        it "returns error message" do
          do_request
          expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
        end
      end

      context "when user is authenticated as not admin" do
        let!(:user) { create(:user) }
        let(:params) { {} }
        let(:headers) { auth_token_for(user) }

        it "returns unauthorized" do
          do_request
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when user is authenticated as admin" do
        let!(:user) { create(:user, admin: true) }
        let(:headers) { auth_token_for(user) }

        it "returns unauthorized" do
          do_request
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "when params are missing" do
      let!(:user) { create(:user, admin: true) }
      let(:params) { {} }
      let(:headers) { auth_token_for(user) }

      it "returns bad_request" do
        do_request
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "when params are not correct" do
      let!(:user) { create(:user, admin: true) }
      let(:params) { { start_date: "01-06-2000", end_date: "05-06-2000" } }
      let(:headers) { auth_token_for(user) }

      it "returns unprocessable_entity" do
        do_request
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error message" do
        do_request
        expect(response.parsed_body).to eq({ "errors" => ["invalid data format, it must be dd/mm/yyyy"] })
      end
    end

    context "when data is correct" do
      let(:year) { 2000 }
      let!(:user) { create(:user, admin: true) }
      let(:params) { { start_date: "01/06/2000", end_date: "05/06/2000" } }
      let(:headers) { auth_token_for(user) }
      let(:month) { 6 }
      let(:start_date) { DateTime.new(year, month, 1) }
      let(:end_date) { DateTime.new(year, month, 5) }

      before do
        # out of range
        create_list(:event_procedure, 1, date: start_date - 1.day)
        # included on range
        create_list(:event_procedure, 2, date: start_date, user:)
        create_list(:event_procedure, 3, date: start_date + 1.day)
        create_list(:event_procedure, 4, date: end_date, user:)
        # out of range
        create_list(:event_procedure, 5, date: end_date + 1.day)
      end

      it "returns ok" do
        do_request
        expect(response).to have_http_status(:ok)
      end

      it "body contains dashboard_data" do
        do_request
        expect(response.parsed_body).to eq(
          {
            "days" => { "01/06/2000" => 2,
                        "02/06/2000" => 3,
                        "03/06/2000" => 0,
                        "04/06/2000" => 0,
                        "05/06/2000" => 4 },
            "end_date" => "05/06/2000",
            "events_amount" => 9,
            "start_date" => "01/06/2000"
          }
        )
      end

      context "when it is filtered by user_id" do
        let(:params) { { start_date: "01/06/2000", end_date: "05/06/2000", user_id: user.id } }

        it "returns only data for the user from params" do
          do_request
          expect(response.parsed_body).to eq(
            {
              "days" => { "01/06/2000" => 2,
                          "02/06/2000" => 0,
                          "03/06/2000" => 0,
                          "04/06/2000" => 0,
                          "05/06/2000" => 4 },
              "end_date" => "05/06/2000",
              "events_amount" => 6,
              "start_date" => "01/06/2000"
            }
          )
        end
      end
    end
  end
end
