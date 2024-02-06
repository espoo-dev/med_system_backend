# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::Create, type: :operation do
  describe ".result" do
    context "when params are valid" do
      it "is successful" do
        user = create(:user)
        params = {
          procedure_id: create(:procedure).id,
          patient_id: create(:patient).id,
          hospital_id: create(:hospital).id,
          health_insurance_id: create(:health_insurance).id,
          patient_service_number: "1234567890",
          date: Time.zone.now,
          urgency: false,
          room_type: EventProcedures::RoomTypes::WARD
        }

        result = described_class.result(attributes: params, user_id: user.id)

        expect(result).to be_success
      end

      it "creates a new event_procedure" do
        user = create(:user)
        params = {
          procedure_id: create(:procedure, amount_cents: 1000).id,
          patient_id: create(:patient).id,
          hospital_id: create(:hospital).id,
          health_insurance_id: create(:health_insurance).id,
          patient_service_number: "1234567890",
          date: Time.zone.now.to_date,
          urgency: true,
          room_type: EventProcedures::RoomTypes::WARD
        }

        result = described_class.result(attributes: params, user_id: user.id)

        expect(result.event_procedure).to be_persisted
        expect(result.event_procedure.attributes.symbolize_keys).to include(
          procedure_id: params[:procedure_id],
          patient_id: params[:patient_id],
          hospital_id: params[:hospital_id],
          health_insurance_id: params[:health_insurance_id],
          patient_service_number: params[:patient_service_number],
          date: params[:date],
          urgency: params[:urgency],
          room_type: params[:room_type],
          total_amount_cents: result.event_procedure.total_amount_cents
        )
        expect(result.event_procedure.total_amount_cents).to eq(1300)
      end
    end

    context "when params are invalid" do
      it "fails" do
        user = create(:user)
        result = described_class.result(attributes: {}, user_id: user.id)

        expect(result).to be_failure
      end

      it "returns invalid event_procedure" do
        user = create(:user)
        result = described_class.result(attributes: {}, user_id: user.id)

        expect(result.event_procedure).not_to be_valid
      end

      it "returns errors" do
        user = create(:user)
        result = described_class.result(attributes: {}, user_id: user.id)

        expect(result.error.full_messages).to eq(
          [
            "Health insurance must exist",
            "Hospital must exist",
            "Patient must exist",
            "Procedure must exist",
            "Date can't be blank",
            "Patient service number can't be blank",
            "Room type can't be blank"
          ]
        )
      end
    end
  end
end
