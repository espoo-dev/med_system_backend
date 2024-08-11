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
          user = create(:user)
          medical_shifts = create_list(:medical_shift, 2, user: user)
          get api_v1_medical_shifts_path, headers: auth_token_for(user)

          expect(response.parsed_body["medical_shifts"].count).to eq(2)
          expect(response.parsed_body["medical_shifts"]).to include(
            {
              "id" => medical_shifts.second.id,
              "hospital_name" => medical_shifts.second.hospital.name,
              "workload" => medical_shifts.second.workload,
              "date" => medical_shifts.second.date.strftime("%d/%m/%Y"),
              "amount_cents" => medical_shifts.second.amount.format,
              "was_paid" => medical_shifts.second.was_paid
            },
            {
              "id" => medical_shifts.first.id,
              "hospital_name" => medical_shifts.first.hospital.name,
              "workload" => medical_shifts.first.workload,
              "date" => medical_shifts.first.date.strftime("%d/%m/%Y"),
              "amount_cents" => medical_shifts.first.amount.format,
              "was_paid" => medical_shifts.first.was_paid
            }
          )
        end

        context "when has pagination via page and per_page" do
          it "paginates medical_shifts" do
            user = create(:user)
            create_list(:medical_shift, 5, user: user)
            headers = auth_token_for(user)

            get api_v1_medical_shifts_path, params: { page: 1, per_page: 2 }, headers: headers

            expect(response.parsed_body["medical_shifts"].count).to eq(2)
          end
        end

        context "when has filters by month" do
          it "returns medical_shifts per month" do
            user = create(:user)
            february_medical_shift = create(:medical_shift, date: "2023-02-15", user: user)
            _september_medical_shift = create(:medical_shift, date: "2023-09-26", user: user)

            get api_v1_medical_shifts_path, params: { month: "2" }, headers: auth_token_for(user)

            expect(response.parsed_body["medical_shifts"].count).to eq(1)
            expect(response.parsed_body["medical_shifts"].first["id"]).to eq(february_medical_shift.id)
          end
        end

        context "when has filters by hospital" do
          it "returns medical_shifts per hospital" do
            user = create(:user)
            hospital = create(:hospital)
            hospital_medical_shift = create(:medical_shift, hospital: hospital, user: user)
            _another_hospital_medical_shift = create(:medical_shift)

            get api_v1_medical_shifts_path, params: { hospital_id: hospital.id }, headers: auth_token_for(user)

            expect(response.parsed_body["medical_shifts"].count).to eq(1)
            expect(response.parsed_body["medical_shifts"].first["id"]).to eq(hospital_medical_shift.id)
          end
        end

        context "when filtering by payd" do
          it "returns paid medical_shifts" do
            user = create(:user)
            paid_medical_shifts = create_list(:medical_shift, 2, was_paid: true, user: user)
            _unpaid_medical_shifts = create(:medical_shift, was_paid: false, user: user)

            get api_v1_medical_shifts_path, params: { payd: "true" }, headers: auth_token_for(user)

            expect(response.parsed_body["medical_shifts"].count).to eq(2)
            expect(response.parsed_body["medical_shifts"]).to include(
              {
                "id" => paid_medical_shifts.second.id,
                "hospital_name" => paid_medical_shifts.second.hospital.name,
                "workload" => paid_medical_shifts.second.workload,
                "date" => paid_medical_shifts.second.date.strftime("%d/%m/%Y"),
                "amount_cents" => paid_medical_shifts.second.amount.format,
                "was_paid" => paid_medical_shifts.second.was_paid
              },
              {
                "id" => paid_medical_shifts.first.id,
                "hospital_name" => paid_medical_shifts.first.hospital.name,
                "workload" => paid_medical_shifts.first.workload,
                "date" => paid_medical_shifts.first.date.strftime("%d/%m/%Y"),
                "amount_cents" => paid_medical_shifts.first.amount.format,
                "was_paid" => paid_medical_shifts.first.was_paid
              }
            )
          end

          it "returns unpaid medical_shifts" do
            user = create(:user)
            _paid_medical_shifts = create(:medical_shift, was_paid: true, user: user)
            unpaid_medical_shifts = create_list(:medical_shift, 2, was_paid: false, user: user)

            get api_v1_medical_shifts_path, params: { payd: "false" }, headers: auth_token_for(user)

            expect(response.parsed_body["medical_shifts"].count).to eq(2)
            expect(response.parsed_body["medical_shifts"]).to include(
              {
                "id" => unpaid_medical_shifts.second.id,
                "hospital_name" => unpaid_medical_shifts.second.hospital.name,
                "workload" => unpaid_medical_shifts.second.workload,
                "date" => unpaid_medical_shifts.second.date.strftime("%d/%m/%Y"),
                "amount_cents" => unpaid_medical_shifts.second.amount.format,
                "was_paid" => unpaid_medical_shifts.second.was_paid
              },
              {
                "id" => unpaid_medical_shifts.first.id,
                "hospital_name" => unpaid_medical_shifts.first.hospital.name,
                "workload" => unpaid_medical_shifts.first.workload,
                "date" => unpaid_medical_shifts.first.date.strftime("%d/%m/%Y"),
                "amount_cents" => unpaid_medical_shifts.first.amount.format,
                "was_paid" => unpaid_medical_shifts.first.was_paid
              }
            )
          end
        end
      end

      context "when there are no medical_shifts" do
        it "returns empty array" do
          get api_v1_medical_shifts_path, headers: auth_token_for(create(:user))

          expect(response.parsed_body.symbolize_keys).to eq(
            {
              total: "R$0.00",
              total_payd: "R$0.00",
              total_unpaid: "R$0.00",
              medical_shifts: []
            }
          )
        end
      end
    end
  end

  describe "POST api/v1/medical_shifts" do
    context "when user is not authenticated" do
      it "retuns unauthorized status" do
        post api_v1_medical_shifts_path, params: { hospital_id: create(:hospital).id }

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        post api_v1_medical_shifts_path, params: { was_paid: true }

        expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
      end
    end

    context "when user is authenticated" do
      context "with valid params" do
        it "returns created status" do
          params = {
            hospital_id: create(:hospital).id,
            workload: MedicalShifts::Workloads::SIX,
            date: "2024-01-29 10:51:23",
            amount_cents: 1,
            was_paid: false
          }

          post api_v1_medical_shifts_path, params: params, headers: auth_token_for(create(:user))

          expect(response).to have_http_status(:created)
        end

        it "creates a medical_shift" do
          hospital = create(:hospital)
          params = {
            hospital_id: hospital.id,
            workload: MedicalShifts::Workloads::SIX,
            date: "2024-01-29 10:51:23",
            amount_cents: 1,
            was_paid: false
          }

          post api_v1_medical_shifts_path, params: params, headers: auth_token_for(create(:user))

          expect(response.parsed_body.symbolize_keys).to include(
            id: MedicalShift.last.id,
            hospital_name: hospital.name,
            workload: params[:workload],
            date: MedicalShift.last.date.strftime("%d/%m/%Y"),
            amount_cents: MedicalShift.last.amount.format,
            was_paid: params[:was_paid]
          )
        end
      end

      context "with invalid params" do
        it "returns unprocessable_content status" do
          params = { amount_cents: 1, was_paid: false }

          post api_v1_medical_shifts_path, params: params, headers: auth_token_for(create(:user))

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns error message" do
          params = { amount_cents: 1, was_paid: false }

          post api_v1_medical_shifts_path, params: params, headers: auth_token_for(create(:user))

          expect(response.parsed_body).to eq(
            {
              "date" => ["can't be blank"],
              "hospital" => ["must exist"],
              "workload" => ["can't be blank"]
            }
          )
        end
      end
    end
  end

  describe "PUT api/v1/medical_shifts/:id" do
    context "when user is not authenticated" do
      it "retuns unauthorized status" do
        put api_v1_medical_shift_path(create(:medical_shift)), params: { hospital_id: create(:hospital).id }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      context "when updating another user's medical_shift" do
        it "returns unauthorized status" do
          user = create(:user)
          medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX)
          params = { workload: MedicalShifts::Workloads::TWELVE }
          put api_v1_medical_shift_path(medical_shift), params: params, headers: auth_token_for(user)

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when updating user's medical_shift" do
        context "with valid params" do
          it "returns ok status" do
            user = create(:user)
            medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX, user: user)
            params = { workload: MedicalShifts::Workloads::TWELVE }

            put api_v1_medical_shift_path(medical_shift), params: params, headers: auth_token_for(user)

            expect(response).to have_http_status(:ok)
          end

          it "updates medical_shift" do
            user = create(:user)
            medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX, user: user)
            params = { workload: MedicalShifts::Workloads::TWELVE }

            put api_v1_medical_shift_path(medical_shift), params: params, headers: auth_token_for(user)

            expect(response.parsed_body.symbolize_keys).to include(
              id: medical_shift.id,
              hospital_name: medical_shift.hospital.name,
              workload: params[:workload],
              date: medical_shift.date.strftime("%d/%m/%Y"),
              amount_cents: medical_shift.amount.format,
              was_paid: medical_shift.was_paid
            )
          end
        end

        context "with invalid params" do
          it "returns unprocessable_content status" do
            user = create(:user)
            medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX, user: user)
            params = { workload: nil }

            put api_v1_medical_shift_path(medical_shift), params: params, headers: auth_token_for(user)

            expect(response).to have_http_status(:unprocessable_content)
          end

          it "returns error message" do
            user = create(:user)
            medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX, user: user)
            params = { workload: nil }

            put api_v1_medical_shift_path(medical_shift), params: params, headers: auth_token_for(user)

            expect(response.parsed_body).to eq({ "workload" => ["can't be blank"] })
          end
        end
      end
    end
  end

  describe "DELETE /api/v1/medical_shifts/:id" do
    let(:user) { create(:user) }
    let(:medical_shift) { create(:medical_shift, user_id: user.id) }

    context "when user is authenticated" do
      let(:headers) { auth_token_for(user) }

      before { delete "/api/v1/medical_shifts/#{medical_shift.id}", headers: headers }

      it { expect(response).to have_http_status(:ok) }

      context "when medical_shift cannot be destroyed" do
        before do
          allow(MedicalShift).to receive(:find).with(medical_shift.id.to_s).and_return(medical_shift)
          allow(medical_shift).to receive(:destroy).and_return(false)

          delete "/api/v1/medical_shifts/#{medical_shift.id}", headers: headers
        end

        it { expect(response).to have_http_status(:unprocessable_content) }
        it { expect(response.parsed_body).to eq("cannot_destroy") }
      end
    end

    context "when user is not authenticated" do
      let(:medical_shift) { create(:medical_shift, user_id: user.id) }

      before { delete "/api/v1/medical_shifts/#{medical_shift.id}", headers: {} }

      it { expect(response).to have_http_status(:unauthorized) }
    end
  end
end
