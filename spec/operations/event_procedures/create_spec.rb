# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::Create, type: :operation do
  describe ".result" do
    context "when params are valid" do
      it "is successful" do
        user = create(:user)
        params = {
          hospital_id: create(:hospital).id,
          patient_service_number: "1234567890",
          date: Time.zone.now,
          urgency: false,
          room_type: EventProcedures::RoomTypes::WARD,
          payment: EventProcedures::Payments::HEALTH_INSURANCE,
          patient_attributes: { id: create(:patient).id },
          procedure_attributes: { id: create(:procedure).id },
          health_insurance_attributes: { id: create(:health_insurance).id }
        }

        result = described_class.result(attributes: params, user_id: user.id)

        expect(result).to be_success
      end

      it "creates a new event_procedure" do
        user = create(:user)
        params = {
          hospital_id: create(:hospital).id,
          patient_service_number: "1234567890",
          date: Time.zone.now.to_date,
          urgency: true,
          room_type: EventProcedures::RoomTypes::WARD,
          payment: EventProcedures::Payments::HEALTH_INSURANCE,
          patient_attributes: { id: create(:patient).id },
          procedure_attributes: { id: create(:procedure, amount_cents: 1000).id },
          health_insurance_attributes: { id: create(:health_insurance).id }
        }

        result = described_class.result(attributes: params, user_id: user.id)

        expect(result.event_procedure).to be_persisted
        expect(result.event_procedure.attributes.symbolize_keys).to include(
          procedure_id: params[:procedure_attributes][:id],
          patient_id: params[:patient_attributes][:id],
          hospital_id: params[:hospital_id],
          health_insurance_id: params[:health_insurance_attributes][:id],
          patient_service_number: params[:patient_service_number],
          date: params[:date],
          urgency: params[:urgency],
          room_type: params[:room_type],
          payment: params[:payment],
          total_amount_cents: result.event_procedure.total_amount_cents
        )
        expect(result.event_procedure.total_amount_cents).to eq(1300)
      end

      context "when create a new patient" do
        it "creates and does not duplicate the creation" do
          user = create(:user)
          params = {
            hospital_id: create(:hospital).id,
            health_insurance_id: create(:health_insurance).id,
            patient_service_number: "1234567890",
            date: Time.zone.now.to_date,
            urgency: true,
            room_type: EventProcedures::RoomTypes::WARD,
            payment: EventProcedures::Payments::HEALTH_INSURANCE,
            patient_attributes: { id: nil, name: "John Doe", user_id: user.id },
            procedure_attributes: { id: create(:procedure, amount_cents: 1000).id },
            health_insurance_attributes: { id: create(:health_insurance).id }
          }

          expect { described_class.call(attributes: params, user_id: user.id) }.to change(Patient, :count).by(1)
        end
      end

      context "when create a new procedure" do
        context "when procedure attributes are valid" do
          it "does not duplicate the creation" do
            user = create(:user)
            procedure_attributes = {
              id: nil,
              name: "procedure name",
              code: "code-1234",
              amount_cents: 100,
              description: "procedure description",
              custom: true,
              user_id: user.id
            }
            params = {
              hospital_id: create(:hospital).id,
              health_insurance_id: create(:health_insurance).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: true,
              room_type: EventProcedures::RoomTypes::WARD,
              payment: EventProcedures::Payments::HEALTH_INSURANCE,
              patient_attributes: { id: create(:patient).id },
              procedure_attributes: procedure_attributes,
              health_insurance_attributes: { id: create(:health_insurance).id }
            }

            expect { described_class.call(attributes: params, user_id: user.id) }.to change(Procedure, :count).by(1)
          end
        end

        context "when procedure attributes are invalid" do
          it "returns error" do
            user = create(:user)
            _some_procedure = create(:procedure, code: "code-1234", user_id: user.id)
            procedure_attributes = {
              id: nil,
              name: nil,
              code: "code-1234",
              amount_cents: 100,
              description: "procedure description",
              custom: true,
              user_id: user.id
            }
            params = {
              hospital_id: create(:hospital).id,
              health_insurance_id: create(:health_insurance).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: true,
              room_type: EventProcedures::RoomTypes::WARD,
              payment: EventProcedures::Payments::HEALTH_INSURANCE,
              patient_attributes: { id: create(:patient).id },
              procedure_attributes: procedure_attributes,
              health_insurance_attributes: { id: create(:health_insurance).id }
            }

            result = described_class.result(attributes: params, user_id: user.id)

            expect(result).to be_failure
            expect(result.error.full_messages).to eq(["Name can't be blank"])
          end
        end
      end

      context "when create a new health_insurance" do
        context "when health_insurance attributes are valid" do
          it "does not duplicate the creation" do
            user = create(:user)
            health_insurance_attributes = {
              id: nil,
              name: "Health Insurance Name",
              custom: true,
              user_id: user.id
            }
            params = {
              hospital_id: create(:hospital).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: nil,
              room_type: nil,
              payment: EventProcedures::Payments::OTHERS,
              patient_attributes: { id: create(:patient).id },
              procedure_attributes: { id: create(:procedure).id },
              health_insurance_attributes: health_insurance_attributes
            }

            expect do
              described_class.call(attributes: params, user_id: user.id)
            end.to change(HealthInsurance, :count).by(1)
          end
        end

        context "when health_insurance attributes are invalid" do
          it "returns error" do
            user = create(:user)
            _some_health_insurance = create(:health_insurance, custom: true, user_id: user.id)
            health_insurance_attributes = {
              id: nil,
              name: nil,
              custom: nil,
              user_id: user.id
            }
            params = {
              hospital_id: create(:hospital).id,
              patient_service_number: "1234567890",
              date: Time.zone.now.to_date,
              urgency: nil,
              room_type: nil,
              payment: EventProcedures::Payments::OTHERS,
              patient_attributes: { id: create(:patient).id },
              procedure_attributes: { id: create(:procedure).id },
              health_insurance_attributes: health_insurance_attributes
            }

            result = described_class.result(attributes: params, user_id: user.id)

            expect(result).to be_failure
            expect(result.error.full_messages).to eq(["Name can't be blank"])
          end
        end
      end
    end

    context "when params are invalid" do
      it "fails" do
        user = create(:user)
        attributes = { patient_attributes: {}, procedure_attributes: {}, health_insurance_attributes: {} }
        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result).to be_failure
      end

      it "returns invalid event_procedure" do
        user = create(:user)
        procedure = create(:procedure)
        patient = create(:patient)
        health_insurance = create(:health_insurance)
        attributes = {
          patient_attributes: { id: patient.id },
          procedure_attributes: { id: procedure.id },
          health_insurance_attributes: { id: health_insurance.id }
        }
        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.event_procedure).not_to be_valid
      end

      it "returns errors" do
        user = create(:user)
        procedure = create(:procedure)
        patient = create(:patient)
        health_insurance = create(:health_insurance)
        attributes = {
          patient_attributes: { id: patient.id },
          procedure_attributes: { id: procedure.id },
          health_insurance_attributes: { id: health_insurance.id }
        }
        result = described_class.result(attributes: attributes, user_id: user.id)

        expect(result.error.full_messages).to eq(
          [
            "Hospital must exist",
            "Date can't be blank",
            "Patient service number can't be blank",
            "Room type can't be blank",
            "Urgency is not included in the list"
          ]
        )
      end

      context "when patient attributes are invalid" do
        it "returns errors" do
          user = create(:user)
          procedure = create(:procedure)
          health_insurance = create(:health_insurance)
          attributes = {
            patient_attributes: { id: nil },
            procedure_attributes: { id: procedure.id },
            health_insurance_attributes: { id: health_insurance.id }
          }
          result = described_class.result(attributes: attributes, user_id: user.id)

          expect(result.error.full_messages).to eq(
            [
              "Hospital must exist",
              "Patient must exist",
              "Date can't be blank",
              "Patient service number can't be blank",
              "Room type can't be blank",
              "Urgency is not included in the list"
            ]
          )
        end
      end

      context "when procedure attributes are invalid" do
        it "returns errors" do
          user = create(:user)
          patient = create(:patient)
          health_insurance = create(:health_insurance)
          attributes = {
            hospital_id: create(:hospital).id,
            patient_service_number: "1234567890",
            date: Time.zone.now.to_date,
            urgency: true,
            room_type: EventProcedures::RoomTypes::WARD,
            payment: EventProcedures::Payments::HEALTH_INSURANCE,
            patient_attributes: { id: patient.id },
            procedure_attributes: { id: nil },
            health_insurance_attributes: { id: health_insurance.id }
          }
          result = described_class.result(attributes: attributes, user_id: user.id)

          expect(result.error.full_messages).to eq(
            [
              "Name can't be blank",
              "Code can't be blank",
              "Amount cents can't be blank",
              "Amount cents is not a number"
            ]
          )
        end
      end
    end
  end
end
