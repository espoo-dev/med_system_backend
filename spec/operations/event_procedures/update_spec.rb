# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::Update, type: :operation do
  describe ".result" do
    context "with valid attributes" do
      it "updates event_procedure" do
        cbhpm = create(:cbhpm)
        procedure = create(:procedure)
        create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
        create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
        event_procedure = create(:event_procedure, procedure: procedure, cbhpm: cbhpm)
        attributes = { date: Time.zone.yesterday, payd: true }
        described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(event_procedure.reload.attributes).to include(
          "date" => attributes[:date],
          "payd" => attributes[:payd]
        )
      end

      context "when patient_attributes are provided" do
        it "update event_procedure association patient" do
          old_patient = create(:patient, name: "Old Patient")
          new_patient = create(:patient, name: "New Patient name")
          cbhpm = create(:cbhpm)
          procedure = create(:procedure)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
          create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
          event_procedure = create(:event_procedure, procedure: procedure, cbhpm: cbhpm, patient: old_patient)
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
          cbhpm = create(:cbhpm)
          procedure = create(:procedure)
          create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
          create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
          event_procedure = create(:event_procedure, procedure: procedure, cbhpm: cbhpm, patient: patient)
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

      context "when procedure_attributes are provided" do
        context "when valid attributes" do
          it "update event_procedure association procedure" do
            old_procedure = create(:procedure, name: "old_procedure_name")
            new_procedure = create(:procedure, name: "new_procedure_name")
            cbhpm = create(:cbhpm)
            create(:cbhpm_procedure, procedure: old_procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:cbhpm_procedure, procedure: new_procedure, cbhpm: cbhpm, anesthetic_port: "4A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "4A", amount_cents: 2000)
            event_procedure = create(:event_procedure, procedure: old_procedure, cbhpm: cbhpm)
            attributes = {
              procedure_attributes: { id: new_procedure.id }
            }

            result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

            expect(result.event_procedure.reload.procedure.id).to eq(new_procedure.id)
            expect(result.event_procedure.reload.procedure.name).to eq("new_procedure_name")
          end

          it "creates a new procedure and does not duplicate the creation" do
            user = create(:user)
            old_procedure = create(:procedure, name: "old_procedure_name")
            cbhpm = create(:cbhpm)
            create(:cbhpm_procedure, procedure: old_procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            event_procedure = create(:event_procedure, procedure: old_procedure, cbhpm: cbhpm)
            procedure_attributes = {
              id: nil,
              name: "new_procedure_name",
              code: "code-1234",
              amount_cents: 100,
              description: "procedure description",
              custom: true,
              user_id: user.id
            }
            attributes = {
              procedure_attributes: procedure_attributes
            }

            expect do
              described_class.result(id: event_procedure.id.to_s, attributes: attributes)
            end.to change(Procedure, :count).by(1)

            result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

            expect(result.event_procedure.reload.procedure.id).to eq(Procedure.last.id)
            expect(result.event_procedure.reload.procedure.name).to eq("new_procedure_name")
          end
        end

        context "when invalid attributes" do
          it "returns error" do
            user = create(:user)
            old_procedure = create(:procedure, name: "old_procedure_name", code: "code-1234")
            cbhpm = create(:cbhpm)
            create(:cbhpm_procedure, procedure: old_procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            event_procedure = create(:event_procedure, procedure: old_procedure, cbhpm: cbhpm)
            procedure_attributes = {
              id: nil,
              name: nil,
              code: "code-1234",
              amount_cents: 100,
              description: "procedure description",
              custom: true,
              user_id: user.id
            }
            attributes = {
              procedure_attributes: procedure_attributes
            }

            result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

            expect(result.error).to eq(["Name can't be blank"])
          end
        end
      end

      context "when health_insurance_attributes are provided" do
        context "when valid attributes" do
          it "update event_procedure association health_insurance" do
            old_health_insurance = create(:health_insurance, name: "old_health_insurance_name")
            new_health_insurance = create(:health_insurance, name: "new_health_insurance_name")
            cbhpm = create(:cbhpm)
            procedure = create(:procedure)
            create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            event_procedure = create(
              :event_procedure, procedure: procedure, cbhpm: cbhpm,
              health_insurance: old_health_insurance
            )
            attributes = {
              health_insurance_attributes: { id: new_health_insurance.id }
            }

            result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

            expect(result.event_procedure.reload.health_insurance.id).to eq(new_health_insurance.id)
            expect(result.event_procedure.reload.health_insurance.name).to eq("new_health_insurance_name")
          end

          it "creates a new health_insurance and does not duplicate the creation" do
            user = create(:user)
            old_health_insurance = create(:health_insurance, name: "old_health_insurance_name")
            cbhpm = create(:cbhpm)
            procedure = create(:procedure)
            create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            event_procedure = create(
              :event_procedure, procedure: procedure, cbhpm: cbhpm,
              health_insurance: old_health_insurance
            )
            health_insurance_attributes = {
              id: nil,
              name: "new_health_insurance_name",
              custom: true,
              user_id: user.id
            }
            attributes = {
              health_insurance_attributes: health_insurance_attributes
            }

            expect do
              described_class.result(id: event_procedure.id.to_s, attributes: attributes)
            end.to change(HealthInsurance, :count).by(1)

            result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

            expect(result.event_procedure.reload.health_insurance.id).to eq(HealthInsurance.last.id)
            expect(result.event_procedure.reload.health_insurance.name).to eq("new_health_insurance_name")
          end
        end

        context "when invalid attributes" do
          it "returns error" do
            user = create(:user)
            old_health_insurance = create(:health_insurance, name: "old_health_insurance_name")
            cbhpm = create(:cbhpm)
            procedure = create(:procedure)
            create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
            create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
            event_procedure = create(
              :event_procedure, procedure: procedure, cbhpm: cbhpm,
              health_insurance: old_health_insurance
            )
            health_insurance_attributes = {
              id: nil,
              name: nil,
              custom: true,
              user_id: user.id
            }
            attributes = {
              health_insurance_attributes: health_insurance_attributes
            }

            result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

            expect(result.error).to eq(["Name can't be blank"])
          end
        end
      end

      it "update event_procedure total_amount_cents" do
        procedure = create(:procedure, amount_cents: 1000)
        cbhpm = create(:cbhpm)
        create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
        create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
        event_procedure = create(
          :event_procedure,
          cbhpm: cbhpm,
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
        procedure = create(:procedure, amount_cents: 1000)
        cbhpm = create(:cbhpm)
        create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
        create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
        event_procedure = create(:event_procedure, cbhpm: cbhpm, procedure: procedure)
        attributes = { date: Time.zone.yesterday, payd: true }
        result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(result).to be_success
      end
    end

    context "with invalid attributes" do
      let!(:cbhpm) { create(:cbhpm) }
      let!(:procedure) { create(:procedure) }
      let!(:event_procedure) { create(:event_procedure, procedure: procedure, cbhpm: cbhpm) }

      before do
        create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
        create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
      end

      it "fails" do
        attributes = { date: nil, payd: false }
        result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(result).to be_failure
      end

      it "returns invalid event_procedure" do
        attributes = { date: nil }
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
