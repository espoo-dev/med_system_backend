# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::BuildTotalAmountCents, type: :operation do
  describe ".result" do
    it "returns a success" do
      cbhpm = create(:cbhpm)
      procedure = create(:procedure)
      create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
      create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
      event_procedure = create(:event_procedure, procedure: procedure, cbhpm: cbhpm)

      expect(described_class.result(event_procedure: event_procedure)).to be_success
    end

    context "when urgency is true" do
      it "adds 30% to the total amount" do
        cbhpm = create(:cbhpm)
        procedure = create(:procedure)
        create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
        create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 43_300)
        event_procedure = create(:event_procedure, procedure: procedure, cbhpm: cbhpm, urgency: true)

        result = described_class.result(event_procedure: event_procedure)

        expect(result.total_amount_cents).to eq(56_290) # 433,00 + 30% equals to R$562,90
      end
    end

    context "when room_type is apartment" do
      it "doubles the total amount" do
        cbhpm = create(:cbhpm)
        procedure = create(:procedure)
        create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
        create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
        event_procedure = create(
          :event_procedure, procedure: procedure, cbhpm: cbhpm,
          room_type: EventProcedures::RoomTypes::APARTMENT
        )

        result = described_class.result(event_procedure: event_procedure)

        expect(result.total_amount_cents).to eq(2000)
      end
    end

    context "when urgency is true and room_type is 'apartment'" do
      it "(adds 30% of the procedure value) and (another 100% of the procedure value) to total_amount_cents" do
        cbhpm = create(:cbhpm)
        procedure = create(:procedure)
        create(:cbhpm_procedure, procedure: procedure, cbhpm: cbhpm, anesthetic_port: "1A")
        create(:port_value, cbhpm: cbhpm, anesthetic_port: "1A", amount_cents: 1000)
        event_procedure = create(
          :event_procedure, procedure: procedure, cbhpm: cbhpm,
          room_type: EventProcedures::RoomTypes::APARTMENT,
          urgency: true
        )

        result = described_class.result(event_procedure: event_procedure)

        expect(result.total_amount_cents).to eq(2300)
      end
    end
  end
end
