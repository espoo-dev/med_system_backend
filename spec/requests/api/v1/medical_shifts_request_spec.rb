# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MedicalShifts" do
  let!(:user) { create(:user) }
  let(:headers) { auth_token_for(user) }

  describe "GET ap1/v1/medical_shifts" do
    let(:path) { api_v1_medical_shifts_path }
    let(:http_method) { :get }
    let(:params) { {} }

    context "when user is authenticated" do
      context "when there are medical_shifts" do
        it "returns ok" do
          get path, headers: headers

          expect(response).to have_http_status(:ok)
        end

        it "returns medical_shifts" do
          medical_shifts = create_list(:medical_shift, 2, user: user)
          get path, headers: headers
          second_hospital_name = medical_shifts.second.hospital_name
          second_workload = medical_shifts.second.workload_humanize
          second_shift = medical_shifts.second.shift
          first_hospital_name = medical_shifts.first.hospital_name
          first_workload = medical_shifts.first.workload_humanize
          first_shift = medical_shifts.first.shift

          expect(response.parsed_body["medical_shifts"].count).to eq(2)
          expect(response.parsed_body["medical_shifts"]).to include(
            {
              "id" => medical_shifts.second.id,
              "medical_shift_recurrence_id" => medical_shifts.second.medical_shift_recurrence_id.presence,
              "hospital_name" => medical_shifts.second.hospital_name,
              "workload" => medical_shifts.second.workload_humanize,
              "date" => medical_shifts.second.start_date.strftime("%d/%m/%Y"),
              "hour" => medical_shifts.second.start_hour.strftime("%H:%M"),
              "amount_cents" => medical_shifts.second.amount.format,
              "paid" => medical_shifts.second.paid,
              "shift" => medical_shifts.second.shift,
              "title" => "#{second_hospital_name} | #{second_workload} | #{second_shift}",
              "color" => medical_shifts.second.color
            },
            {
              "id" => medical_shifts.first.id,
              "medical_shift_recurrence_id" => medical_shifts.first.medical_shift_recurrence_id.presence,
              "hospital_name" => medical_shifts.first.hospital_name,
              "workload" => medical_shifts.first.workload_humanize,
              "date" => medical_shifts.first.start_date.strftime("%d/%m/%Y"),
              "hour" => medical_shifts.first.start_hour.strftime("%H:%M"),
              "amount_cents" => medical_shifts.first.amount.format,
              "paid" => medical_shifts.first.paid,
              "shift" => medical_shifts.first.shift,
              "title" => "#{first_hospital_name} | #{first_workload} | #{first_shift}",
              "color" => medical_shifts.first.color
            }
          )
        end

        context "when has pagination via page and per_page" do
          it "paginates medical_shifts" do
            create_list(:medical_shift, 5, user: user)
            get path, params: { page: 1, per_page: 2 }, headers: headers

            expect(response.parsed_body["medical_shifts"].count).to eq(2)
          end
        end

        context "when has filters by month" do
          it "returns medical_shifts per month" do
            february_medical_shift = create(:medical_shift, start_date: "2023-02-15", user: user)
            _september_medical_shift = create(:medical_shift, start_date: "2023-09-26", user: user)

            get path, params: { month: "2" }, headers: headers

            expect(response.parsed_body["medical_shifts"].count).to eq(1)
            expect(response.parsed_body["medical_shifts"].first["id"]).to eq(february_medical_shift.id)
          end

          it "returns medical_shifts amount data per month" do
            create(
              :medical_shift, start_date: "2023-02-15", user:, amount_cents: 1000,
              paid: true
            )
            create(
              :medical_shift, start_date: "2023-02-15", user:, amount_cents: 2000,
              paid: false
            )
            _september_medical_shift = create(:medical_shift, start_date: "2023-09-26", user: user)

            get path, params: { month: "2" }, headers: headers

            expect(response.parsed_body["total"]).to eq("R$30,00")
            expect(response.parsed_body["total_paid"]).to eq("R$10,00")
            expect(response.parsed_body["total_unpaid"]).to eq("R$20,00")
          end
        end

        context "when has filters by hospital" do
          it "returns medical_shifts per hospital" do
            hospital = create(:hospital)
            hospital_medical_shift = create(:medical_shift, hospital_name: hospital.name, user: user)
            _another_hospital_medical_shift = create(:medical_shift)

            get path, params: { hospital_name: hospital.name }, headers: headers

            expect(response.parsed_body["medical_shifts"].count).to eq(1)
            expect(response.parsed_body["medical_shifts"].first["id"]).to eq(hospital_medical_shift.id)
          end
        end

        context "when filtering by paid" do
          it "returns paid medical_shifts" do
            paid_medical_shifts = create_list(:medical_shift, 2, paid: true, user: user)
            _unpaid_medical_shifts = create(:medical_shift, paid: false, user: user)
            second_hospital_name = paid_medical_shifts.second.hospital_name
            second_workload = paid_medical_shifts.second.workload_humanize
            second_shift = paid_medical_shifts.second.shift
            first_hospital_name = paid_medical_shifts.first.hospital_name
            first_workload = paid_medical_shifts.first.workload_humanize
            first_shift = paid_medical_shifts.first.shift

            get path, params: { paid: "true" }, headers: headers

            expect(response.parsed_body["medical_shifts"].count).to eq(2)
            expect(response.parsed_body["medical_shifts"]).to include(
              {
                "id" => paid_medical_shifts.second.id,
                "medical_shift_recurrence_id" => paid_medical_shifts.second.medical_shift_recurrence_id.presence,
                "hospital_name" => paid_medical_shifts.second.hospital_name,
                "workload" => paid_medical_shifts.second.workload_humanize,
                "date" => paid_medical_shifts.second.start_date.strftime("%d/%m/%Y"),
                "hour" => paid_medical_shifts.second.start_hour.strftime("%H:%M"),
                "amount_cents" => paid_medical_shifts.second.amount.format,
                "paid" => paid_medical_shifts.second.paid,
                "shift" => paid_medical_shifts.second.shift,
                "title" => "#{second_hospital_name} | #{second_workload} | #{second_shift}",
                "color" => paid_medical_shifts.second.color
              },
              {
                "id" => paid_medical_shifts.first.id,
                "medical_shift_recurrence_id" => paid_medical_shifts.first.medical_shift_recurrence_id.presence,
                "hospital_name" => paid_medical_shifts.first.hospital_name,
                "workload" => paid_medical_shifts.first.workload_humanize,
                "date" => paid_medical_shifts.first.start_date.strftime("%d/%m/%Y"),
                "hour" => paid_medical_shifts.first.start_hour.strftime("%H:%M"),
                "amount_cents" => paid_medical_shifts.first.amount.format,
                "paid" => paid_medical_shifts.first.paid,
                "shift" => paid_medical_shifts.first.shift,
                "title" => "#{first_hospital_name} | #{first_workload} | #{first_shift}",
                "color" => paid_medical_shifts.first.color
              }
            )
          end

          it "returns unpaid medical_shifts" do
            _paid_medical_shifts = create(:medical_shift, paid: true, user: user)
            unpaid_medical_shifts = create_list(:medical_shift, 2, paid: false, user: user)
            second_hospital_name = unpaid_medical_shifts.second.hospital_name
            second_workload = unpaid_medical_shifts.second.workload_humanize
            second_shift = unpaid_medical_shifts.second.shift
            first_hospital_name = unpaid_medical_shifts.first.hospital_name
            first_workload = unpaid_medical_shifts.first.workload_humanize
            first_shift = unpaid_medical_shifts.first.shift

            get path, params: { paid: "false" }, headers: headers

            expect(response.parsed_body["medical_shifts"].count).to eq(2)
            expect(response.parsed_body["medical_shifts"]).to include(
              {
                "id" => unpaid_medical_shifts.second.id,
                "medical_shift_recurrence_id" => unpaid_medical_shifts.second.medical_shift_recurrence_id.presence,
                "hospital_name" => unpaid_medical_shifts.second.hospital_name,
                "workload" => unpaid_medical_shifts.second.workload_humanize,
                "date" => unpaid_medical_shifts.second.start_date.strftime("%d/%m/%Y"),
                "hour" => unpaid_medical_shifts.second.start_hour.strftime("%H:%M"),
                "amount_cents" => unpaid_medical_shifts.second.amount.format,
                "paid" => unpaid_medical_shifts.second.paid,
                "shift" => unpaid_medical_shifts.second.shift,
                "title" => "#{second_hospital_name} | #{second_workload} | #{second_shift}",
                "color" => unpaid_medical_shifts.second.color
              },
              {
                "id" => unpaid_medical_shifts.first.id,
                "medical_shift_recurrence_id" => unpaid_medical_shifts.first.medical_shift_recurrence_id.presence,
                "hospital_name" => unpaid_medical_shifts.first.hospital_name,
                "workload" => unpaid_medical_shifts.first.workload_humanize,
                "date" => unpaid_medical_shifts.first.start_date.strftime("%d/%m/%Y"),
                "hour" => unpaid_medical_shifts.first.start_hour.strftime("%H:%M"),
                "amount_cents" => unpaid_medical_shifts.first.amount.format,
                "paid" => unpaid_medical_shifts.first.paid,
                "shift" => unpaid_medical_shifts.first.shift,
                "title" => "#{first_hospital_name} | #{first_workload} | #{first_shift}",
                "color" => unpaid_medical_shifts.first.color
              }
            )
          end
        end
      end

      context "when there are no medical_shifts" do
        it "returns empty array" do
          get path, headers: headers

          expect(response.parsed_body.symbolize_keys).to eq(
            {
              total: "R$0,00",
              total_paid: "R$0,00",
              total_unpaid: "R$0,00",
              medical_shifts: []
            }
          )
        end
      end
    end

    include_context "when user is not authenticated"
  end

  describe "POST api/v1/medical_shifts" do
    let(:path) { api_v1_medical_shifts_path }

    context "when user is not authenticated" do
      it "retuns unauthorized status" do
        post path, params: { hospital_name: create(:hospital).id }

        expect(response).to have_http_status(:unauthorized)
      end

      it "returns error message" do
        post path, params: { paid: true }

        expect(response.parsed_body["error_description"]).to eq(["Invalid token"])
      end
    end

    context "when user is authenticated" do
      context "with valid params" do
        it "returns created status" do
          params = {
            hospital_name: create(:hospital).name,
            workload: MedicalShifts::Workloads::SIX,
            start_date: "2024-01-29",
            start_hour: "10:51:23",
            amount_cents: 1,
            paid: false
          }

          post path, params: params, headers: headers

          expect(response).to have_http_status(:created)
        end

        it "creates a medical_shift" do
          params = {
            hospital_name: create(:hospital).name,
            workload: MedicalShifts::Workloads::SIX,
            start_date: "2024-01-29",
            start_hour: "10:51:23",
            amount_cents: 1,
            paid: false,
            color: "#000000"
          }

          post path, params: params, headers: headers

          hospital_name = MedicalShift.last.hospital_name
          workload = MedicalShift.last.workload_humanize
          shift = MedicalShift.last.shift

          expect(response.parsed_body.symbolize_keys).to include(
            id: MedicalShift.last.id,
            hospital_name: MedicalShift.last.hospital_name,
            workload: MedicalShift.last.workload_humanize,
            date: MedicalShift.last.start_date.strftime("%d/%m/%Y"),
            hour: MedicalShift.last.start_hour.strftime("%H:%M"),
            amount_cents: MedicalShift.last.amount.format,
            paid: params[:paid],
            shift: MedicalShift.last.shift,
            title: "#{hospital_name} | #{workload} | #{shift}",
            color: "#000000"
          )
        end
      end

      context "with invalid params" do
        it "returns unprocessable_content status" do
          params = { amount_cents: 1, paid: false }

          post path, params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns error message" do
          params = { amount_cents: 1, paid: false }

          post path, params: params, headers: headers

          expect(response.parsed_body).to eq(
            {
              "start_date" => ["can't be blank"],
              "start_hour" => ["can't be blank"],
              "workload" => ["can't be blank"]
            }
          )
        end
      end
    end
  end

  describe "PUT api/v1/medical_shifts/:id" do
    let(:http_method) { :put }

    context "when user is not authenticated" do
      it "retuns unauthorized status" do
        put api_v1_medical_shift_path(create(:medical_shift)), params: { hospital_name: create(:hospital).name }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is authenticated" do
      context "when updating another user's medical_shift" do
        it "returns not_found to prevent ID enumeration" do
          medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX)
          params = { workload: MedicalShifts::Workloads::TWELVE }
          put api_v1_medical_shift_path(medical_shift), params: params, headers: headers

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when updating user's medical_shift" do
        context "with valid params" do
          it "returns ok status" do
            medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX, user: user)
            params = { workload: MedicalShifts::Workloads::TWELVE }

            put api_v1_medical_shift_path(medical_shift), params: params, headers: headers

            expect(response).to have_http_status(:ok)
          end

          it "updates medical_shift" do
            medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX, user: user)
            params = { workload: MedicalShifts::Workloads::TWELVE }

            put api_v1_medical_shift_path(medical_shift), params: params, headers: headers

            hospital_name = medical_shift.reload.hospital_name
            workload = medical_shift.reload.workload_humanize
            shift = medical_shift.reload.shift

            expect(response.parsed_body.symbolize_keys).to include(
              id: medical_shift.id,
              hospital_name: medical_shift.hospital_name,
              workload: workload,
              date: medical_shift.start_date.strftime("%d/%m/%Y"),
              hour: medical_shift.start_hour.strftime("%H:%M"),
              amount_cents: medical_shift.amount.format,
              paid: medical_shift.paid,
              shift: medical_shift.reload.shift,
              title: "#{hospital_name} | #{workload} | #{shift}"
            )
          end
        end

        context "with invalid params" do
          it "returns unprocessable_content status" do
            medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX, user: user)
            params = { workload: nil }

            put api_v1_medical_shift_path(medical_shift), params: params, headers: headers

            expect(response).to have_http_status(:unprocessable_content)
          end

          it "returns error message" do
            medical_shift = create(:medical_shift, workload: MedicalShifts::Workloads::SIX, user: user)
            params = { workload: nil }

            put api_v1_medical_shift_path(medical_shift), params: params, headers: headers

            expect(response.parsed_body).to eq({ "workload" => ["can't be blank"] })
          end
        end
      end
    end
  end

  describe "DELETE /api/v1/medical_shifts/:id" do
    let(:path) { "/api/v1/medical_shifts/#{medical_shift.id}" }
    let(:http_method) { :delete }
    let(:medical_shift) { create(:medical_shift, user_id: user.id) }
    let(:params) { {} }

    context "when user is authenticated" do
      include_examples "delete request returns ok", MedicalShift

      context "when does not find medical_shifts" do
        let(:fake_id) { 9999 }

        before do
          delete "/api/v1/medical_shifts/#{fake_id}", headers: headers
        end

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response.parsed_body[:error]).to include("Couldn't find MedicalShift with 'id'=#{fake_id}") }
      end

      context "when medical_shift cannot be destroyed" do
        before do
          allow(MedicalShift).to receive(:find).with(medical_shift.id.to_s).and_return(medical_shift)
          allow(medical_shift).to receive(:destroy).and_return(false)

          delete path, headers: headers
        end

        it { expect(response).to have_http_status(:unprocessable_content) }
        it { expect(response.parsed_body).to eq("cannot_destroy") }
      end
    end

    include_context "when user is not authenticated"
  end

  describe "GET ap1/v1/medical_shifts/hospital_name_suggestion" do
    let(:path) { hospital_name_suggestion_api_v1_medical_shifts_path }
    let(:http_method) { :get }
    let(:params) { {} }

    context "when user is authenticated" do
      context "when there are medical_shifts" do
        it "returns ok" do
          get path, headers: headers

          expect(response).to have_http_status(:ok)
        end

        it "returns hospital_names" do
          medical_shifts_same_hospital_name = create_list(:medical_shift, 2, user: user)
          medical_shifts_another_hospital_name = create(
            :medical_shift,
            hospital_name: "Another hostpital Test",
            user: user
          )
          create_list(:medical_shift, 4, hospital_name: "Another user")

          get path, headers: headers

          expect(response.parsed_body["names"].count).to eq(2)
          expect(response.parsed_body["names"]).to eq(
            [
              medical_shifts_another_hospital_name.hospital_name,
              medical_shifts_same_hospital_name.first.hospital_name
            ]
          )
        end
      end

      context "when there are no medical_shifts" do
        it "returns empty array" do
          get path, headers: headers

          expect(response.parsed_body.symbolize_keys).to eq({ names: [] })
        end
      end
    end

    include_context "when user is not authenticated"
  end

  describe "GET ap1/v1/medical_shifts/amount_suggestions" do
    let(:path) { amount_suggestions_api_v1_medical_shifts_path }
    let(:http_method) { :get }
    let(:params) { {} }

    context "when user is authenticated" do
      it "returns amounts_cents" do
        create_list(:medical_shift, 2, user:, amount_cents: 200_000)
        create_list(:medical_shift, 3, user:, amount_cents: 300_000)
        create_list(:medical_shift, 4, hospital_name: "Another user")

        get path, headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["amounts_cents"]).to eq(["R$2.000,00", "R$3.000,00"])
      end
    end

    include_context "when user is not authenticated"
  end
end
