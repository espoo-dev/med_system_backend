# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MedicalShiftRecurrences" do
  let(:user) { create(:user) }
  let(:auth_headers) { auth_token_for(user) }

  describe "GET /api/v1/medical_shift_recurrences" do
    let!(:user_recurrence_one) do
      create(
        :medical_shift_recurrence,
        user: user,
        created_at: 2.days.ago
      )
    end

    let!(:user_recurrence_two) do
      create(
        :medical_shift_recurrence,
        user: user,
        created_at: 1.day.ago
      )
    end

    let!(:other_user_recurrence) do
      create(
        :medical_shift_recurrence,
        created_at: 3.days.ago
      )
    end

    let!(:deleted_recurrence) do
      create(
        :medical_shift_recurrence, :deleted,
        user: user
      )
    end

    context "with authentication" do
      it "returns ok status" do
        get "/api/v1/medical_shift_recurrences", headers: auth_headers

        expect(response).to have_http_status(:ok)
      end

      it "returns only current user recurrences" do
        get "/api/v1/medical_shift_recurrences", headers: auth_headers

        body = response.parsed_body
        ids = body.pluck(:id)

        expect(ids).to include(user_recurrence_one.id, user_recurrence_two.id)
        expect(ids).not_to include(other_user_recurrence.id)
      end

      it "does not return deleted recurrences" do
        get "/api/v1/medical_shift_recurrences", headers: auth_headers

        body = response.parsed_body
        ids = body.pluck(:id)

        expect(ids).not_to include(deleted_recurrence.id)
      end

      it "returns recurrences ordered by created_at desc" do
        get "/api/v1/medical_shift_recurrences", headers: auth_headers

        body = response.parsed_body

        expect(body.first["id"]).to eq(user_recurrence_two.id)
        expect(body.second["id"]).to eq(user_recurrence_one.id)
      end

      it "returns recurrences with correct attributes" do
        get "/api/v1/medical_shift_recurrences", headers: auth_headers

        body = response.parsed_body
        first_recurrence = body.first

        expect(first_recurrence).to include(
          "id",
          "frequency",
          "start_date",
          "workload",
          "hospital_name",
          "amount_cents"
        )
      end

      it "returns empty array when user has no recurrences" do
        user_without_recurrences = create(:user)
        headers = auth_token_for(user_without_recurrences)

        get "/api/v1/medical_shift_recurrences", headers: headers

        body = response.parsed_body

        expect(body).to be_empty
      end
    end

    context "without authentication" do
      it "returns unauthorized status" do
        get "/api/v1/medical_shift_recurrences"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/medical_shift_recurrences" do
    context "with valid params" do
      context "when creating weekly recurrence" do
        let(:valid_params) do
          {
            medical_shift_recurrence: {
              frequency: "weekly",
              day_of_week: 1,
              start_date: Time.zone.tomorrow,
              workload: MedicalShifts::Workloads::SIX,
              start_hour: "19:00:00",
              hospital_name: "Hospital Teste",
              amount_cents: 120_000
            }
          }
        end

        it "returns created status" do
          post "/api/v1/medical_shift_recurrences",
            params: valid_params,
            headers: auth_headers

          expect(response).to have_http_status(:created)
        end

        it "creates a medical shift recurrence" do
          expect do
            post "/api/v1/medical_shift_recurrences",
              params: valid_params,
              headers: auth_headers
          end.to change(MedicalShiftRecurrence, :count).by(1)
        end

        it "returns the created recurrence" do
          post "/api/v1/medical_shift_recurrences",
            params: valid_params,
            headers: auth_headers

          body = response.parsed_body

          expect(body["medical_shift_recurrence"]).to be_present
          expect(body["medical_shift_recurrence"]["frequency"]).to eq("weekly")
          expect(body["medical_shift_recurrence"]["day_of_week"]).to eq(1)
        end

        it "generates shifts immediately" do
          post "/api/v1/medical_shift_recurrences",
            params: valid_params,
            headers: auth_headers

          body = response.parsed_body

          expect(body["shifts_generated"]).to be > 0
        end

        it "creates shifts for the recurrence" do
          expect do
            post "/api/v1/medical_shift_recurrences",
              params: valid_params,
              headers: auth_headers
          end.to change(MedicalShift, :count).by_at_least(8)
        end

        it "assigns recurrence to current user" do
          post "/api/v1/medical_shift_recurrences",
            params: valid_params,
            headers: auth_headers

          recurrence = MedicalShiftRecurrence.last

          expect(recurrence.user).to eq(user)
        end
      end

      context "when creating biweekly recurrence" do
        let(:biweekly_params) do
          {
            medical_shift_recurrence: {
              frequency: "biweekly",
              day_of_week: 5,
              start_date: Time.zone.tomorrow,
              workload: MedicalShifts::Workloads::TWELVE,
              start_hour: "07:00:00",
              hospital_name: "Hospital Central",
              amount_cents: 200_000
            }
          }
        end

        it "creates biweekly recurrence successfully" do
          post "/api/v1/medical_shift_recurrences",
            params: biweekly_params,
            headers: auth_headers

          expect(response).to have_http_status(:created)

          body = response.parsed_body
          expect(body["medical_shift_recurrence"]["frequency"]).to eq("biweekly")
        end
      end

      context "when creating monthly_fixed_day recurrence" do
        let(:monthly_params) do
          {
            medical_shift_recurrence: {
              frequency: "monthly_fixed_day",
              day_of_month: 15,
              start_date: Time.zone.tomorrow,
              workload: MedicalShifts::Workloads::SIX,
              start_hour: "19:00:00",
              hospital_name: "Hospital Regional",
              amount_cents: 150_000
            }
          }
        end

        it "creates monthly recurrence successfully" do
          post "/api/v1/medical_shift_recurrences",
            params: monthly_params,
            headers: auth_headers

          expect(response).to have_http_status(:created)

          body = response.parsed_body
          expect(body["medical_shift_recurrence"]["frequency"]).to eq("monthly_fixed_day")
          expect(body["medical_shift_recurrence"]["day_of_month"]).to eq(15)
        end
      end

      context "with end_date" do
        let(:params_with_end_date) do
          {
            medical_shift_recurrence: {
              frequency: "weekly",
              day_of_week: 3,
              start_date: Time.zone.tomorrow,
              end_date: 2.months.from_now.to_date,
              workload: MedicalShifts::Workloads::SIX,
              start_hour: "19:00:00",
              hospital_name: "Hospital Teste",
              amount_cents: 120_000
            }
          }
        end

        it "creates recurrence with end_date" do
          post "/api/v1/medical_shift_recurrences",
            params: params_with_end_date,
            headers: auth_headers

          expect(response).to have_http_status(:created)

          body = response.parsed_body
          expect(body["medical_shift_recurrence"]["end_date"]).to be_present
        end
      end
    end

    context "with invalid params" do
      context "when frequency is missing" do
        let(:invalid_params) do
          {
            medical_shift_recurrence: {
              day_of_week: 1,
              start_date: Time.zone.tomorrow,
              workload: MedicalShifts::Workloads::SIX,
              start_hour: "19:00:00",
              hospital_name: "Hospital Teste",
              amount_cents: 120_000
            }
          }
        end

        it "returns unprocessable entity status" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "does not create a recurrence" do
          expect do
            post "/api/v1/medical_shift_recurrences",
              params: invalid_params,
              headers: auth_headers
          end.not_to change(MedicalShiftRecurrence, :count)
        end

        it "returns error messages" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          body = response.parsed_body
          expect(body["errors"]).to be_present
        end
      end

      context "when day_of_week is missing for weekly frequency" do
        let(:invalid_params) do
          {
            medical_shift_recurrence: {
              frequency: "weekly",
              start_date: Time.zone.tomorrow,
              workload: MedicalShifts::Workloads::SIX,
              start_hour: "19:00:00",
              hospital_name: "Hospital Teste",
              amount_cents: 120_000
            }
          }
        end

        it "returns unprocessable content status" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns validation error" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          body = response.parsed_body
          expect(body["errors"]).to include(match(/Day of week/))
        end
      end

      context "when day_of_month is missing for monthly_fixed_day frequency" do
        let(:invalid_params) do
          {
            medical_shift_recurrence: {
              frequency: "monthly_fixed_day",
              start_date: Time.zone.tomorrow,
              workload: MedicalShifts::Workloads::SIX,
              start_hour: "19:00:00",
              hospital_name: "Hospital Teste",
              amount_cents: 120_000
            }
          }
        end

        it "returns unprocessable content status" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns validation error" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          body = response.parsed_body
          expect(body["errors"]).to include(match(/Day of month/))
        end
      end

      context "when start_date is in the past" do
        let(:invalid_params) do
          {
            medical_shift_recurrence: {
              frequency: "weekly",
              day_of_week: 1,
              start_date: Time.zone.yesterday,
              workload: MedicalShifts::Workloads::SIX,
              start_hour: "19:00:00",
              hospital_name: "Hospital Teste",
              amount_cents: 120_000
            }
          }
        end

        it "returns unprocessable content status" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns validation error" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          body = response.parsed_body
          expect(body["errors"]).to include(match(/Start date/))
        end
      end

      context "when end_date is before start_date" do
        let(:invalid_params) do
          {
            medical_shift_recurrence: {
              frequency: "weekly",
              day_of_week: 1,
              start_date: Time.zone.tomorrow,
              end_date: 1.month.ago.to_date,
              workload: MedicalShifts::Workloads::SIX,
              start_hour: "19:00:00",
              hospital_name: "Hospital Teste",
              amount_cents: 120_000
            }
          }
        end

        it "returns unprocessable content status" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns validation error" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          body = response.parsed_body
          expect(body["errors"]).to include(match(/End date/))
        end
      end

      context "when required fields are missing" do
        let(:invalid_params) do
          {
            medical_shift_recurrence: {
              frequency: "weekly",
              day_of_week: 1
            }
          }
        end

        it "returns unprocessable content status" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns multiple validation errors" do
          post "/api/v1/medical_shift_recurrences",
            params: invalid_params,
            headers: auth_headers

          body = response.parsed_body
          errors = body["errors"]

          expect(errors).to include(
            match(/Start date/),
            match(/Workload/),
            match(/Start hour/),
            match(/Hospital name/)
          )
        end
      end
    end

    context "without authentication" do
      it "returns unauthorized status" do
        post "/api/v1/medical_shift_recurrences",
          params: { medical_shift_recurrence: {} }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/medical_shift_recurrences/:id" do
    let!(:recurrence) do
      create(
        :medical_shift_recurrence,
        user: user,
        frequency: "weekly",
        day_of_week: 1,
        start_date: Date.tomorrow
      )
    end

    before do
      result = MedicalShiftRecurrences::Create.result(
        attributes: recurrence.attributes.slice(
          "frequency", "day_of_week", "start_date", "workload",
          "start_hour", "hospital_name", "amount_cents"
        ),
        user_id: user.id
      )

      result.shifts_created.each do |shift|
        shift.update!(medical_shift_recurrence: recurrence)
      end
    end

    context "with valid recurrence" do
      it "returns ok status" do
        delete "/api/v1/medical_shift_recurrences/#{recurrence.id}",
          headers: auth_headers

        expect(response).to have_http_status(:ok)
      end

      it "soft deletes the recurrence" do
        delete "/api/v1/medical_shift_recurrences/#{recurrence.id}",
          headers: auth_headers

        expect(recurrence.reload.deleted?).to be true
      end

      it "returns success message" do
        delete "/api/v1/medical_shift_recurrences/#{recurrence.id}",
          headers: auth_headers

        body = response.parsed_body

        expect(body["message"]).to eq("Recurrence cancelled successfully")
      end

      it "returns the number of shifts cancelled" do
        future_shifts_count = recurrence.medical_shifts
          .where("start_date >= ?", Date.current)
          .count

        delete "/api/v1/medical_shift_recurrences/#{recurrence.id}",
          headers: auth_headers

        body = response.parsed_body

        expect(body["shifts_cancelled"]).to eq(future_shifts_count)
      end

      it "soft deletes future shifts" do
        delete "/api/v1/medical_shift_recurrences/#{recurrence.id}",
          headers: auth_headers

        active_future_shifts = MedicalShift
          .where(medical_shift_recurrence: recurrence)
          .where("start_date >= ?", Date.current)
          .count

        expect(active_future_shifts).to eq(0)
      end
    end

    context "when recurrence does not exist" do
      it "returns not found status" do
        delete "/api/v1/medical_shift_recurrences/999999",
          headers: auth_headers

        expect(response).to have_http_status(:not_found)
      end

      it "returns error message" do
        delete "/api/v1/medical_shift_recurrences/999999",
          headers: auth_headers

        body = response.parsed_body

        expect(body["error"]).to eq("Recurrence not found")
      end
    end

    context "when recurrence belongs to another user" do
      let(:other_user_recurrence) do
        create(:medical_shift_recurrence)
      end

      it "returns not found status" do
        delete "/api/v1/medical_shift_recurrences/#{other_user_recurrence.id}",
          headers: auth_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when recurrence is already deleted" do
      before do
        recurrence.destroy
      end

      it "returns not found status" do
        delete "/api/v1/medical_shift_recurrences/#{recurrence.id}",
          headers: auth_headers

        expect(response).to have_http_status(:not_found)
      end
    end

    context "without authentication" do
      it "returns unauthorized status" do
        delete "/api/v1/medical_shift_recurrences/#{recurrence.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when operation fails" do
      before do
        allow(MedicalShiftRecurrences::Cancel).to receive(:call)
          .and_return(
            double(
              success?: false,
              error: "Something went wrong"
            )
          )
      end

      it "returns unprocessable content status" do
        delete "/api/v1/medical_shift_recurrences/#{recurrence.id}",
          headers: auth_headers

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns error message" do
        delete "/api/v1/medical_shift_recurrences/#{recurrence.id}",
          headers: auth_headers

        body = response.parsed_body

        expect(body["errors"]).to eq("Something went wrong")
      end
    end
  end
end
