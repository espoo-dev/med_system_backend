# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::Update, type: :operation do
  describe ".result" do
    context "with valid attributes" do
      it "updates event_procedure" do
        event_procedure = create(:event_procedure)
        attributes = { date: Time.zone.yesterday, payd_at: Time.zone.tomorrow }
        described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(event_procedure.reload.attributes).to include(
          "date" => attributes[:date],
          "payd_at" => attributes[:payd_at]
        )
      end

      context "when patient_attributes are provided" do
        it "update event_procedure association patient" do
          old_patient = create(:patient, name: "Old Patient")
          new_patient = create(:patient, name: "New Patient name")
          event_procedure = create(:event_procedure, patient: old_patient)
          attributes = {
            urgency: true,
            room_type: EventProcedures::RoomTypes::WARD,
            patient_attributes: { id: new_patient.id, name: nil }
          }
          result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

          expect(result.event_procedure.reload.patient.id).to eq(new_patient.id)
          expect(result.event_procedure.reload.patient.name).to eq("New Patient name")
        end

        it "creates a new patient and does not duplicate the creation" do
          patient = create(:patient, name: "Old Patient")
          user = create(:user)
          event_procedure = create(:event_procedure, patient:)
          attributes = {
            urgency: true,
            room_type: EventProcedures::RoomTypes::WARD,
            patient_attributes: { id: nil, name: "John Doe", user_id: user.id }
          }

          expect do
            described_class.result(id: event_procedure.id.to_s, attributes: attributes)
          end.to change(Patient, :count).by(1)
        end
      end

      it "update event_procedure total_amount_cents" do
        procedure = create(:procedure, amount_cents: 1000)
        event_procedure = create(
          :event_procedure,
          procedure: procedure,
          urgency: false,
          room_type: EventProcedures::RoomTypes::WARD
        )
        attributes = { urgency: true, room_type: EventProcedures::RoomTypes::APARTMENT }

        result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(result.event_procedure.total_amount_cents).to eq(2300)
        expect(result.event_procedure.total_amount.format).to eq("R$23.00")
      end

      it "returns success" do
        event_procedure = create(:event_procedure)
        attributes = { date: Time.zone.yesterday, payd_at: Time.zone.tomorrow }
        result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(result).to be_success
      end
    end

    context "with invalid attributes" do
      let!(:event_procedure) { create(:event_procedure) }

      it "fails" do
        attributes = { date: nil, payd_at: nil }
        result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(result).to be_failure
      end

      it "returns invalid event_procedure" do
        attributes = { date: nil, payd_at: nil }
        result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(result.event_procedure).not_to be_valid
      end

      it "returns errors" do
        attributes = { date: nil }
        result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(result.event_procedure.errors.full_messages).to eq(["Date can't be blank"])
      end
    end
  end
end
