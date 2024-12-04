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
        create_list(:event_procedure, 5, user_id: user.id)
        headers = auth_token_for(user)
        get("/api/v1/event_procedures", params: {}, headers: headers)
      end

      it "returns ok" do
        expect(response).to have_http_status(:ok)
      end

      it "returns all event_procedures" do
        expect(response.parsed_body["event_procedures"].length).to eq(5)
      end
    end

    context "when has filters by month" do
      let!(:user) { create(:user) }

      it "returns event_procedures per month" do
        headers = auth_token_for(user)
        create_list(:event_procedure, 3, date: "2023-02-15", user_id: user.id)
        _month_5_event_procedure = create_list(:event_procedure, 5, date: "2023-05-26", user_id: user.id)

        get("/api/v1/event_procedures", params: { month: "2" }, headers: headers)

        expect(response.parsed_body["event_procedures"].length).to eq(3)
      end
    end

    context "when has filters by year" do
      let!(:user) { create(:user) }

      it "returns event_procedures per month" do
        headers = auth_token_for(user)
        create_list(:event_procedure, 3, date: "2023-02-15", user_id: user.id)
        _month_5_event_procedure = create_list(:event_procedure, 5, date: "2024-05-26", user_id: user.id)

        get("/api/v1/event_procedures", params: { year: "2023" }, headers: headers)

        expect(response.parsed_body["event_procedures"].length).to eq(3)
      end
    end

    context "when filtering by payd" do
      context "when payd is 'true'" do
        let!(:user) { create(:user) }

        it "returns only paid event_procedures" do
          headers = auth_token_for(user)
          create_list(:event_procedure, 3, payd: true, user_id: user.id)
          _unpayd_event_procedures = create_list(:event_procedure, 5, payd: false, user_id: user.id)

          get("/api/v1/event_procedures", params: { payd: "true" }, headers: headers)

          expect(response.parsed_body["event_procedures"].length).to eq(3)
        end
      end

      context "when payd is 'false'" do
        let!(:user) { create(:user) }

        it "returns only unpaid event_procedures" do
          headers = auth_token_for(user)
          create_list(:event_procedure, 3, payd: true, user_id: user.id)
          _unpayd_event_procedures = create_list(:event_procedure, 5, payd: false, user_id: user.id)

          get("/api/v1/event_procedures", params: { payd: "false" }, headers: headers)

          expect(response.parsed_body["event_procedures"].length).to eq(5)
        end
      end
    end

    context "when has filters by hospital name" do
      it "returns event_procedures per hospital name" do
        user = create(:user)
        header_token = auth_token_for(user)
        hospital_cariri = create(:hospital, name: "Hospital de Cariri")
        hospital_sao_matheus = create(:hospital, name: "Hospital São Matheus")
        create(:event_procedure, hospital: hospital_cariri, user_id: user.id)
        create(:event_procedure, hospital: hospital_sao_matheus, user_id: user.id)
        hospital_params = { hospital: { name: "Hospital de Cariri" } }

        get "/api/v1/event_procedures", headers: header_token, params: hospital_params

        expect(response.parsed_body["event_procedures"].length).to eq(1)
        expect(response.parsed_body["event_procedures"].first["hospital"]).to eq("Hospital de Cariri")
      end
    end

    context "when has filters by health_insurance name" do
      it "returns event_procedures per health_insurance name" do
        user = create(:user)
        header_token = auth_token_for(user)
        amil = create(:health_insurance, name: "Amil")
        unimed = create(:health_insurance, name: "Unimed")
        create(:event_procedure, health_insurance: amil, user_id: user.id)
        create(:event_procedure, health_insurance: unimed, user_id: user.id)
        health_insurance_params = { health_insurance: { name: "Unimed" } }

        get "/api/v1/event_procedures", headers: header_token, params: health_insurance_params

        expect(response.parsed_body["event_procedures"].length).to eq(1)
        expect(response.parsed_body["event_procedures"].first["health_insurance"]).to eq("Unimed")
      end
    end

    context "when has pagination via page and per_page" do
      let!(:user) { create(:user) }

      before do
        headers = auth_token_for(user)
        create_list(:event_procedure, 8, user_id: user.id)
        get "/api/v1/event_procedures", params: { page: 2, per_page: 5 }, headers: headers
      end

      it "returns only 3 event_procedures" do
        expect(response.parsed_body["event_procedures"].length).to eq(3)
      end
    end
  end

  describe "POST /api/v1/event_procedures" do
    context "when user is authenticated" do
      context "with valid attributes" do
        context "when patient exists" do
          it "returns created" do
            user = create(:user)
            cbhpm = create(:cbhpm)
            procedure = create(:procedure)
            create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            patient = create(:patient)
            params = {
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

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response).to have_http_status(:created)
          end

          it "returns event_procedure" do
            user = create(:user)
            patient = create(:patient)
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
              payd: true,
              cbhpm_id: cbhpm.id
            }

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

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
              "payd" => true,
              "precedure_value" => "R$200.00",
              "precedure_description" => "nice description"
            )
          end
        end

        context "when patient does not exist" do
          it "returns created" do
            user = create(:user)
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

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response).to have_http_status(:created)
          end

          it "returns event_procedure" do
            user = create(:user)
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

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

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
            user = create(:user)
            patient = create(:patient)
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

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response).to have_http_status(:created)
          end
        end

        context "when health_insurance does not exist" do
          it "returns created" do
            user = create(:user)
            patient = create(:patient)
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

            headers = auth_token_for(user)
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response).to have_http_status(:created)
          end
        end
      end

      context "with invalid attributes" do
        context "when patient_id and patient_name are nil" do
          it "returns unprocessable_content" do
            headers = auth_token_for(create(:user))
            params = {
              patient_attributes: { id: nil },
              procedure_attributes: { id: nil },
              health_insurance_attributes: { id: nil }
            }
            post "/api/v1/event_procedures", params: params, headers: headers

            expect(response).to have_http_status(:unprocessable_content)
          end

          it "returns error message" do
            headers = auth_token_for(create(:user))
            patient = create(:patient)
            procedure = create(:procedure)
            health_insurance = create(:health_insurance)
            params = {
              patient_attributes: { id: patient.id },
              procedure_attributes: { id: procedure.id },
              health_insurance_attributes: { id: health_insurance.id }
            }
            post "/api/v1/event_procedures", params: params, headers: headers

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

    context "when user is not authenticated" do
      it "returns unauthorized" do
        health_insurance = create(:health_insurance)
        procedure = create(:procedure)
        cbhpm = create(:cbhpm)
        create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
        create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
        patient = create(:patient)
        params = {

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

        post "/api/v1/event_procedures", params: params, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PUT /api/v1/event_procedures/:id" do
    context "when user is authenticated" do
      context "with valid attributes and the record belongs to the user" do
        it "returns ok" do
          user = create(:user)
          health_insurance = create(:health_insurance)
          procedure = create(:procedure)
          cbhpm = create(:cbhpm)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
          create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
          patient = create(:patient)
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

          headers = auth_token_for(user)
          put "/api/v1/event_procedures/#{event_procedure.id}", params: params, headers: headers

          expect(response).to have_http_status(:ok)
        end

        it "updates event_procedure" do
          user = create(:user)
          health_insurance = create(:health_insurance)
          procedure = create(:procedure, name: "Angioplastia transluminal")
          patient = create(:patient)
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

          headers = auth_token_for(user)
          put "/api/v1/event_procedures/#{event_procedure.id}", params: params, headers: headers

          expect(event_procedure.reload.urgency).to be true
          expect(event_procedure.reload.room_type).to eq(EventProcedures::RoomTypes::APARTMENT)
          expect(event_procedure.reload.total_amount_cents).to eq(157_300)
        end
      end

      context "with valid attributes and the record not belongs to the user" do
        it "returns unauthorized" do
          user = create(:user)
          health_insurance = create(:health_insurance)
          procedure = create(:procedure)
          cbhpm = create(:cbhpm)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
          create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
          patient = create(:patient)
          event_procedure = create(
            :event_procedure,
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

          headers = auth_token_for(user)
          put "/api/v1/event_procedures/#{event_procedure.id}", params: params, headers: headers

          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "with invalid attributes" do
        it "returns unprocessable_content" do
          user = create(:user)
          health_insurance = create(:health_insurance)
          procedure = create(:procedure)
          cbhpm = create(:cbhpm)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
          create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
          patient = create(:patient)
          event_procedure = create(
            :event_procedure,
            health_insurance_id: health_insurance.id,
            procedure_id: procedure.id,
            patient_id: patient.id,
            cbhpm_id: cbhpm.id,
            user_id: user.id
          )

          headers = auth_token_for(user)
          put "/api/v1/event_procedures/#{event_procedure.id}", params: { date: nil }, headers: headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns error message" do
          user = create(:user)
          health_insurance = create(:health_insurance)
          procedure = create(:procedure)
          cbhpm = create(:cbhpm)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
          create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
          patient = create(:patient)
          event_procedure = create(
            :event_procedure,
            health_insurance_id: health_insurance.id,
            procedure_id: procedure.id,
            patient_id: patient.id,
            cbhpm_id: cbhpm.id,
            user_id: user.id
          )

          headers = auth_token_for(user)
          put "/api/v1/event_procedures/#{event_procedure.id}", params: { date: nil }, headers: headers

          expect(response.parsed_body).to eq(["Date can't be blank"])
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        user = create(:user)
        event_procedure = create(:event_procedure, user_id: user.id)

        params = {
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

        put "/api/v1/event_procedures/#{event_procedure.id}", params: params, headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/event_procedures/:id" do
    context "when user is authenticated" do
      it "returns ok" do
        user = create(:user)
        event_procedure = create(:event_procedure, user_id: user.id)

        headers = auth_token_for(user)
        delete "/api/v1/event_procedures/#{event_procedure.id}", headers: headers

        expect(response.parsed_body[:message]).to eq("#{event_procedure.class} deleted successfully.")
        expect(response).to have_http_status(:ok)
      end

      context "when event_procedure cannot be destroyed" do
        it "returns unprocessable_content" do
          user = create(:user)
          event_procedure = create(:event_procedure, user_id: user.id)

          allow(EventProcedure).to receive(:find).with(event_procedure.id.to_s).and_return(event_procedure)
          allow(event_procedure).to receive(:destroy).and_return(false)

          headers = auth_token_for(user)
          delete "/api/v1/event_procedures/#{event_procedure.id}", headers: headers

          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns error message" do
          user = create(:user)
          event_procedure = create(:event_procedure, user_id: user.id)

          allow(EventProcedure).to receive(:find).with(event_procedure.id.to_s).and_return(event_procedure)
          allow(event_procedure).to receive(:destroy).and_return(false)

          headers = auth_token_for(user)
          delete "/api/v1/event_procedures/#{event_procedure.id}", headers: headers

          expect(response.parsed_body).to eq("cannot_destroy")
        end
      end
    end

    context "when user is not authenticated" do
      it "returns unauthorized" do
        event_procedure = create(:event_procedure)

        delete "/api/v1/event_procedures/#{event_procedure.id}", headers: {}

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
