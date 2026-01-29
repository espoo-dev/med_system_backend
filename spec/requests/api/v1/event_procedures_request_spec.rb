# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EventProcedures" do
  let!(:user) { create(:user) }
  let(:headers) { auth_token_for(user) }

  describe "GET /api/v1/event_procedures" do
    let(:path) { "/api/v1/event_procedures" }
    let(:http_method) { :get }
    let(:params) { {} }

    include_context "when user is not authenticated"

    context "when user is authenticated" do
      before do
        create_list(:event_procedure, 5, user_id: user.id)
        get(path, params: {}, headers: headers)
      end

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end

      it "returns all event_procedures" do
        expect(response.parsed_body["event_procedures"].length).to eq(5)
      end
    end

    context "when checking for N+1 queries" do
      it "does not have N+1 queries" do
        create_list(:event_procedure, 2, user_id: user.id)
        get(path, params: {}, headers: headers) # Warmup

        control_count = count_queries { get(path, params: {}, headers: headers) }

        create_list(:event_procedure, 5, user_id: user.id)

        final_count = count_queries { get(path, params: {}, headers: headers) }

        expect(final_count).to be <= control_count
      end
    end

    context "when has filters by month" do
      it "returns event_procedures per month" do
        create_list(:event_procedure, 3, date: "2023-02-15", user_id: user.id)
        _month_5_event_procedure = create_list(:event_procedure, 5, date: "2023-05-26", user_id: user.id)

        get(path, params: { month: "2" }, headers: headers)

        expect(response.parsed_body["event_procedures"].length).to eq(3)
      end
    end

    context "when has filters by year" do
      it "returns event_procedures per month" do
        create_list(:event_procedure, 3, date: "2023-02-15", user_id: user.id)
        _month_5_event_procedure = create_list(:event_procedure, 5, date: "2024-05-26", user_id: user.id)

        get(path, params: { year: "2023" }, headers: headers)

        expect(response.parsed_body["event_procedures"].length).to eq(3)
      end
    end

    context "when filtering by paid" do
      context "when paid is 'true'" do
        it "returns only paid event_procedures" do
          create_list(:event_procedure, 3, paid: true, user_id: user.id)
          _unpaid_event_procedures = create_list(:event_procedure, 5, paid: false, user_id: user.id)

          get(path, params: { paid: "true" }, headers: headers)

          expect(response.parsed_body["event_procedures"].length).to eq(3)
        end
      end

      context "when paid is 'false'" do
        it "returns only unpaid event_procedures" do
          create_list(:event_procedure, 3, paid: true, user_id: user.id)
          _unpaid_event_procedures = create_list(:event_procedure, 5, paid: false, user_id: user.id)

          get(path, params: { paid: "false" }, headers: headers)

          expect(response.parsed_body["event_procedures"].length).to eq(5)
        end
      end
    end

    context "when has filters by hospital name" do
      it "returns event_procedures per hospital name" do
        hospital_cariri = create(:hospital, name: "Hospital de Cariri")
        hospital_sao_matheus = create(:hospital, name: "Hospital São Matheus")
        create(:event_procedure, hospital: hospital_cariri, user_id: user.id)
        create(:event_procedure, hospital: hospital_sao_matheus, user_id: user.id)
        hospital_params = { hospital: { name: "Hospital de Cariri" } }

        get path, headers: headers, params: hospital_params

        expect(response.parsed_body["event_procedures"].length).to eq(1)
        expect(response.parsed_body["event_procedures"].first["hospital"]).to eq("Hospital de Cariri")
      end
    end

    context "when has filters by health_insurance name" do
      it "returns event_procedures per health_insurance name" do
        amil = create(:health_insurance, name: "Amil")
        unimed = create(:health_insurance, name: "Unimed")
        create(:event_procedure, health_insurance: amil, user_id: user.id)
        create(:event_procedure, health_insurance: unimed, user_id: user.id)
        health_insurance_params = { health_insurance: { name: "Unimed" } }

        get path, headers: headers, params: health_insurance_params

        expect(response.parsed_body["event_procedures"].length).to eq(1)
        expect(response.parsed_body["event_procedures"].first["health_insurance"]).to eq("Unimed")
      end
    end

    context "when has pagination via page and per_page" do
      before do
        procedure = create(:procedure, custom: true, user: user, amount_cents: 5000)
        create_list(:event_procedure, 8, user_id: user.id, total_amount_cents: 5000, procedure: procedure)
        get path, params: { page: 2, per_page: 5 }, headers: headers
      end

      it "returns only 3 event_procedures" do
        expect(response.parsed_body["event_procedures"].length).to eq(3)
      end

      it "returns total values without consider page and per_page params" do
        expect(response.parsed_body["total"]).to eq("R$400,00")
      end
    end
  end

  describe "POST /api/v1/event_procedures" do
    let(:path) { "/api/v1/event_procedures" }
    let(:http_method) { :post }

    context "when user is authenticated" do
      context "with valid attributes" do
        context "when patient exists" do
          it "returns created" do
            cbhpm = create(:cbhpm)
            procedure = create(:procedure)
            create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            patient = create(:patient, user: user)
            params = {
              user_id: user.id,
              hospital_id: create(:hospital).id,
              cbhpm_id: cbhpm.id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: true,
              room_type: EventProcedures::RoomTypes::WARD,
              payment: EventProcedures::Payments::HEALTH_INSURANCE,
              patient_attributes: { id: patient.id },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: create(:health_insurance).id }
            }

            post path, params: params, headers: headers

            expect(response).to have_http_status(:created)
          end

          it "returns event_procedure" do
            patient = create(:patient, user: user)
            procedure = create(:procedure, amount_cents: 20_000, description: "nice description")
            cbhpm = create(:cbhpm)
            create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            health_insurance = create(:health_insurance)
            params = {
              hospital_id: create(:hospital).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: false,
              room_type: EventProcedures::RoomTypes::WARD,
              payment: EventProcedures::Payments::HEALTH_INSURANCE,
              user_id: user.id,
              patient_attributes: { id: patient.id },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: health_insurance.id },
              paid: true,
              cbhpm_id: cbhpm.id
            }

            post path, params: params, headers: headers

            expect(response.parsed_body).to include(
              "procedure" => EventProcedure.last.procedure.name,
              "patient" => patient.name,
              "hospital" => EventProcedure.last.hospital.name,
              "health_insurance" => EventProcedure.last.health_insurance.name,
              "patient_service_number" => params[:patient_service_number],
              "date" => params[:date].strftime("%d/%m/%Y"),
              "room_type" => EventProcedures::RoomTypes::WARD,
              "payment" => EventProcedures::Payments::HEALTH_INSURANCE,
              "urgency" => false,
              "paid" => true,
              "precedure_value" => "R$200.00",
              "precedure_description" => "nice description"
            )
          end
        end

        context "when patient does not exist" do
          it "returns created" do
            procedure = create(:procedure)
            health_insurance = create(:health_insurance)
            cbhpm = create(:cbhpm)
            create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            params = {
              hospital_id: create(:hospital).id,
              cbhpm_id: cbhpm.id,
              health_insurance_id: create(:health_insurance).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: false,
              room_type: EventProcedures::RoomTypes::WARD,
              payment: EventProcedures::Payments::HEALTH_INSURANCE,
              user_id: user.id,
              patient_attributes: { name: "patient 1" },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: health_insurance.id }
            }

            post path, params: params, headers: headers

            expect(response).to have_http_status(:created)
          end

          it "returns event_procedure" do
            procedure = create(:procedure)
            cbhpm = create(:cbhpm)
            create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            health_insurance = create(:health_insurance)
            params = {
              hospital_id: create(:hospital).id,
              cbhpm_id: cbhpm.id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: false,
              room_type: EventProcedures::RoomTypes::WARD,
              payment: EventProcedures::Payments::HEALTH_INSURANCE,
              user_id: user.id,
              patient_attributes: { name: "patient 1" },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: health_insurance.id }
            }

            post path, params: params, headers: headers

            expect(response.parsed_body).to include(
              "procedure" => EventProcedure.last.procedure.name,
              "patient" => "patient 1",
              "hospital" => EventProcedure.last.hospital.name,
              "health_insurance" => EventProcedure.last.health_insurance.name,
              "patient_service_number" => params[:patient_service_number],
              "date" => params[:date].strftime("%d/%m/%Y"),
              "room_type" => EventProcedures::RoomTypes::WARD,
              "payment" => EventProcedures::Payments::HEALTH_INSURANCE,
              "urgency" => false
            )
          end
        end

        context "when procedure does not exist" do
          it "returns created" do
            patient = create(:patient, user: user)
            health_insurance = create(:health_insurance)
            cbhpm = create(:cbhpm)
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            procedure_attributes = attributes_for(:procedure, custom: true)
            params = {
              hospital_id: create(:hospital).id,
              cbhpm_id: cbhpm.id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: nil,
              room_type: nil,
              payment: EventProcedures::Payments::OTHERS,
              user_id: user.id,
              patient_attributes: { id: patient.id },
              procedure_attributes: procedure_attributes,
              health_insurance_attributes: { id: health_insurance.id }
            }

            post path, params: params, headers: headers

            expect(response).to have_http_status(:created)
          end
        end

        context "when health_insurance does not exist" do
          it "returns created" do
            patient = create(:patient, user: user)
            procedure = create(:procedure)
            cbhpm = create(:cbhpm)
            create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            health_insurance_attributes = attributes_for(:health_insurance, custom: true)
            params = {
              hospital_id: create(:hospital).id,
              cbhpm_id: cbhpm.id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: nil,
              room_type: nil,
              payment: EventProcedures::Payments::OTHERS,
              user_id: user.id,
              patient_attributes: { id: patient.id },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: health_insurance_attributes
            }

            post path, params: params, headers: headers

            expect(response).to have_http_status(:created)
          end
        end
      end

      context "with invalid attributes" do
        context "when patient_id and patient_name are nil" do
          it "returns unprocessable_content" do
            params = {
              patient_attributes: { id: nil },
              procedure_attributes: { id: nil },
              health_insurance_attributes: { id: nil }
            }
            post path, params: params, headers: headers

            expect(response).to have_http_status(:unprocessable_content)
          end

          it "returns error message" do
            patient = create(:patient, user: user)
            procedure = create(:procedure)
            health_insurance = create(:health_insurance)
            params = {
              patient_attributes: { id: patient.id },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: health_insurance.id }
            }
            post path, params: params, headers: headers

            expect(response.parsed_body).to eq(
              "cbhpm" => ["must exist"],
              "hospital" => ["must exist"],
              "date" => ["can't be blank"],
              "patient_service_number" => ["can't be blank"],
              "room_type" => ["can't be blank"],
              "urgency" => ["is not included in the list"]
            )
          end
        end
      end
    end

    include_context "when user is not authenticated" do
      let(:health_insurance) { create(:health_insurance) }
      let(:params) do
        {
          hospital_id: create(:hospital).id,
          patient_service_number: "1234567890",
          date: Time.zone.now.to_date,
          urgency: false,
          amount_cents: 100,
          room_type: EventProcedures::RoomTypes::WARD,
          payment: EventProcedures::Payments::HEALTH_INSURANCE,
          patient_attributes: { id: patient.id },
          procedure_attributes: { id: procedure.id },
          health_insurance_attributes: { id: health_insurance.id }
        }
      end
      let(:procedure) { create(:procedure) }
      let(:cbhpm) { create(:cbhpm) }
      let(:patient) { create(:patient) }

      before do
        create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
        create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
      end
    end
  end

  describe "PUT /api/v1/event_procedures/:id" do
    let(:path) { "/api/v1/event_procedures/#{event_procedure.id}" }
    let(:http_method) { :put }

    context "when user is authenticated" do
      context "with valid attributes and the record belongs to the user" do
        it "returns ok" do
          health_insurance = create(:health_insurance)
          procedure = create(:procedure)
          cbhpm = create(:cbhpm)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
          create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
          patient = create(:patient, user: user)
          event_procedure = create(
            :event_procedure,
            health_insurance_id: health_insurance.id,
            procedure_id: procedure.id,
            patient_id: patient.id,
            cbhpm_id: cbhpm.id,
            user_id: user.id
          )

          params = {
            hospital_id: create(:hospital).id,
            cbhpm_id: cbhpm.id,
            health_insurance_id: create(:health_insurance).id,
            patient_service_number: "1234567890",
            date: Time.zone.now.to_date,
            urgency: false,
            room_type: EventProcedures::RoomTypes::WARD,
            payment: EventProcedures::Payments::HEALTH_INSURANCE,
            patient_attributes: { id: patient.id },
            procedure_attributes: { id: procedure.id },
            health_insurance_attributes: { id: health_insurance.id }
          }

          put "/api/v1/event_procedures/#{event_procedure.id}", params: params, headers: headers

          expect(response).to have_http_status(:ok)
        end

        it "updates event_procedure" do
          health_insurance = create(:health_insurance)
          procedure = create(:procedure, name: "Angioplastia transluminal")
          patient = create(:patient, user: user)
          cbhpm = create(:cbhpm)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, port: "12C", anesthetic_port: "6")
          create(:port_value, cbhpm: cbhpm, port: "12C", anesthetic_port: "6", amount_cents: 60_500)
          event_procedure = create(
            :event_procedure,
            health_insurance_id: health_insurance.id,
            procedure_id: procedure.id,
            patient_id: patient.id,
            cbhpm_id: cbhpm.id,
            user_id: user.id,
            urgency: false,
            room_type: EventProcedures::RoomTypes::APARTMENT
          )
          params = {
            urgency: true
          }

          put "/api/v1/event_procedures/#{event_procedure.id}", params: params, headers: headers

          expect(event_procedure.reload.urgency).to be true
          expect(event_procedure.reload.room_type).to eq(EventProcedures::RoomTypes::APARTMENT)
          expect(event_procedure.reload.total_amount_cents).to eq(157_300)
        end
      end

      context "with valid attributes and the record not belongs to the user" do
        it "returns not_found to prevent ID enumeration" do
          other_user = create(:user)
          patient = create(:patient, user: other_user)
          health_insurance = create(:health_insurance)
          procedure = create(:procedure)
          cbhpm = create(:cbhpm)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
          create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
          event_procedure = create(
            :event_procedure, user: other_user,
            health_insurance_id: health_insurance.id,
            procedure_id: procedure.id,
            patient_id: patient.id,
            cbhpm_id: cbhpm.id
          )

          params = {
            hospital_id: create(:hospital).id,
            cbhpm_id: cbhpm.id,
            health_insurance_id: create(:health_insurance).id,
            patient_service_number: "1234567890",
            date: Time.zone.now.to_date,
            urgency: false,
            room_type: EventProcedures::RoomTypes::WARD,
            payment: EventProcedures::Payments::HEALTH_INSURANCE,
            patient_attributes: { id: patient.id },
            procedure_attributes: { id: procedure.id },
            health_insurance_attributes: { id: health_insurance.id }
          }

          put "/api/v1/event_procedures/#{event_procedure.id}", params: params, headers: headers

          expect(response).to have_http_status(:not_found)
        end
      end

      context "with invalid attributes" do
        it "returns unprocessable_content" do
          health_insurance = create(:health_insurance)
          procedure = create(:procedure)
          cbhpm = create(:cbhpm)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
          create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
          patient = create(:patient, user: user)
          event_procedure = create(
            :event_procedure,
            health_insurance_id: health_insurance.id,
            procedure_id: procedure.id,
            patient_id: patient.id,
            cbhpm_id: cbhpm.id,
            user_id: user.id
          )

          put "/api/v1/event_procedures/#{event_procedure.id}", params: { date: nil }, headers: headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns error message" do
          health_insurance = create(:health_insurance)
          procedure = create(:procedure)
          cbhpm = create(:cbhpm)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
          create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
          patient = create(:patient, user: user)
          event_procedure = create(
            :event_procedure,
            health_insurance_id: health_insurance.id,
            procedure_id: procedure.id,
            patient_id: patient.id,
            cbhpm_id: cbhpm.id,
            user_id: user.id
          )

          put "/api/v1/event_procedures/#{event_procedure.id}", params: { date: nil }, headers: headers

          expect(response.parsed_body).to eq(["Date can't be blank"])
        end
      end
    end

    include_context "when user is not authenticated" do
      let(:event_procedure) { create(:event_procedure, user_id: user.id) }

      let(:params) do
        {
          procedure_id: create(:procedure).id,
          patient_id: create(:patient).id,
          hospital_id: create(:hospital).id,
          health_insurance_id: create(:health_insurance).id,
          patient_service_number: "1234567890",
          date: Time.zone.now.to_date,
          urgency: false,
          room_type: EventProcedures::RoomTypes::WARD,
          payment: EventProcedures::Payments::HEALTH_INSURANCE
        }
      end
    end
  end

  describe "DELETE /api/v1/event_procedures/:id" do
    let(:path) { "/api/v1/event_procedures/#{event_procedure.id}" }
    let(:http_method) { :delete }
    let(:params) { {} }

    context "when user is authenticated" do
      let(:event_procedure) { create(:event_procedure, user_id: user.id) }

      include_examples "delete request returns ok", EventProcedure

      context "when event_procedure cannot be destroyed" do
        it "returns unprocessable_content" do
          event_procedure = create(:event_procedure, user_id: user.id)

          allow(EventProcedure).to receive(:find).with(event_procedure.id.to_s).and_return(event_procedure)
          allow(event_procedure).to receive(:destroy).and_return(false)

          delete "/api/v1/event_procedures/#{event_procedure.id}", headers: headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns error message" do
          event_procedure = create(:event_procedure, user_id: user.id)

          allow(EventProcedure).to receive(:find).with(event_procedure.id.to_s).and_return(event_procedure)
          allow(event_procedure).to receive(:destroy).and_return(false)

          delete "/api/v1/event_procedures/#{event_procedure.id}", headers: headers

          expect(response.parsed_body).to eq("cannot_destroy")
        end
      end
    end

    include_context "when user is not authenticated" do
      let(:event_procedure) { create(:event_procedure) }
    end
  end
end
