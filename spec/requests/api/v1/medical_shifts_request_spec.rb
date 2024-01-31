# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MedicalShifts" do
  describe "GET ap1/v1/medical_shifts" do
    context "when user is not authenticated" do
      it "retuns unauthorized status" do
        get api_v1_medical_shifts_path

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        get api_v1_medical_shifts_path

        expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
      end
    end

    context "when user is authenticated" do
      context "when there are medical_shifts" do
        it "returns ok" do
          get api_v1_medical_shifts_path, headers: auth_token_for(create(:user))

          expect(response).to have_http_status(:ok)
        end

        it "returns medical_shifts" do
          medical_shifts = create_list(:medical_shift, 2)
          get api_v1_medical_shifts_path, headers: auth_token_for(create(:user))

          expect(response.parsed_body.count).to eq(2)
          expect(response.parsed_body).to include(
            {
              "id" => medical_shifts.second.id,
              "hospital_name" => medical_shifts.second.hospital.name,
              "workload" => medical_shifts.second.workload,
              "date" => medical_shifts.second.date.strftime("%d/%m/%Y"),
              "amount_cents" => medical_shifts.second.amount_cents,
              "was_paid" => medical_shifts.second.was_paid
            },
            {
              "id" => medical_shifts.first.id,
              "hospital_name" => medical_shifts.first.hospital.name,
              "workload" => medical_shifts.first.workload,
              "date" => medical_shifts.first.date.strftime("%d/%m/%Y"),
              "amount_cents" => medical_shifts.first.amount_cents,
              "was_paid" => medical_shifts.first.was_paid
            }
          )
        end

        context "when has pagination via page and per_page" do
          it "paginates medical_shifts" do
            create_list(:medical_shift, 5)
            headers = auth_token_for(create(:user))

            get api_v1_medical_shifts_path, params: { page: 1, per_page: 2 }, headers: headers

            expect(response.parsed_body.count).to eq(2)
          end
        end

        context "when has filters by month" do
          it "returns medical_shifts per month" do
            february_medical_shift = create(:medical_shift, date: "2023-02-15")
            _september_medical_shift = create(:medical_shift, date: "2023-09-26")

            get api_v1_medical_shifts_path, params: { month: "2" }, headers: auth_token_for(create(:user))

            expect(response.parsed_body.count).to eq(1)
            expect(response.parsed_body.first["id"]).to eq(february_medical_shift.id)
          end
        end

        context "when has filters by hospital" do
          it "returns medical_shifts per hospital" do
            hospital = create(:hospital)
            hospital_medical_shift = create(:medical_shift, hospital: hospital)
            _another_hospital_medical_shift = create(:medical_shift)

            get api_v1_medical_shifts_path, params: { hospital_id: hospital.id }, headers: auth_token_for(create(:user))

            expect(response.parsed_body.count).to eq(1)
            expect(response.parsed_body.first["id"]).to eq(hospital_medical_shift.id)
          end
        end

        context "when filtering by payd" do
          it "returns paid medical_shifts" do
            paid_medical_shifts = create_list(:medical_shift, 2, was_paid: true)
            _unpaid_medical_shifts = create(:medical_shift, was_paid: false)

            get api_v1_medical_shifts_path, params: { payd: "true" }, headers: auth_token_for(create(:user))

            expect(response.parsed_body.count).to eq(2)
            expect(response.parsed_body).to include(
              {
                "id" => paid_medical_shifts.second.id,
                "hospital_name" => paid_medical_shifts.second.hospital.name,
                "workload" => paid_medical_shifts.second.workload,
                "date" => paid_medical_shifts.second.date.strftime("%d/%m/%Y"),
                "amount_cents" => paid_medical_shifts.second.amount_cents,
                "was_paid" => paid_medical_shifts.second.was_paid
              },
              {
                "id" => paid_medical_shifts.first.id,
                "hospital_name" => paid_medical_shifts.first.hospital.name,
                "workload" => paid_medical_shifts.first.workload,
                "date" => paid_medical_shifts.first.date.strftime("%d/%m/%Y"),
                "amount_cents" => paid_medical_shifts.first.amount_cents,
                "was_paid" => paid_medical_shifts.first.was_paid
              }
            )
          end

          it "returns unpaid medical_shifts" do
            _paid_medical_shifts = create(:medical_shift, was_paid: true)
            unpaid_medical_shifts = create_list(:medical_shift, 2, was_paid: false)

            get api_v1_medical_shifts_path, params: { payd: "false" }, headers: auth_token_for(create(:user))

            expect(response.parsed_body.count).to eq(2)
            expect(response.parsed_body).to include(
              {
                "id" => unpaid_medical_shifts.second.id,
                "hospital_name" => unpaid_medical_shifts.second.hospital.name,
                "workload" => unpaid_medical_shifts.second.workload,
                "date" => unpaid_medical_shifts.second.date.strftime("%d/%m/%Y"),
                "amount_cents" => unpaid_medical_shifts.second.amount_cents,
                "was_paid" => unpaid_medical_shifts.second.was_paid
              },
              {
                "id" => unpaid_medical_shifts.first.id,
                "hospital_name" => unpaid_medical_shifts.first.hospital.name,
                "workload" => unpaid_medical_shifts.first.workload,
                "date" => unpaid_medical_shifts.first.date.strftime("%d/%m/%Y"),
                "amount_cents" => unpaid_medical_shifts.first.amount_cents,
                "was_paid" => unpaid_medical_shifts.first.was_paid
              }
            )
          end
        end
      end

      context "when there are no medical_shifts" do
        it "returns empty array" do
          get api_v1_medical_shifts_path, headers: auth_token_for(create(:user))

          expect(response.parsed_body).to eq([])
        end
      end
    end
  end
end
