# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::BuildTotalAmountCents, type: :operation do
  describe ".result" do
    it "returns a success" do
      event_procedure = create(:event_procedure)

      expect(described_class.result(event_procedure: event_procedure)).to be_success
    end

    context "when urgency is true" do
      it "adds 30% to the total amount" do
        procedure = create(:procedure, amount_cents: 10_100) # equals to R$101.00
        event_procedure = create(:event_procedure, urgency: true, procedure_id: procedure.id)

        result = described_class.result(event_procedure: event_procedure)

        expect(result.total_amount_cents).to eq(13_130) # equals to R$131.30
      end
    end

    context "when room_type is apartment" do
      it "doubles the total amount" do
        event_procedure = create(
          :event_procedure,
          room_type: EventProcedures::RoomTypes::APARTMENT,
          procedure: create(:procedure, amount_cents: 1000)
        )

        result = described_class.result(event_procedure: event_procedure)

        expect(result.total_amount_cents).to eq(2000)
      end
    end

    context "when urgency is true and room_type is 'apartment'" do
      it "(adds 30% of the procedure value) and (another 100% of the procedure value) to total_amount_cents" do
        event_procedure = create(
          :event_procedure,
          urgency: true,
          room_type: EventProcedures::RoomTypes::APARTMENT,
          procedure: create(:procedure, amount_cents: 1000)
        )

        result = described_class.result(event_procedure: event_procedure)

        expect(result.total_amount_cents).to eq(2300)
      end
    end
  end
end
