# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::Update, type: :operation do
  describe ".result" do
    context "with valid attributes" do
      let!(:event_procedure) { create(:event_procedure) }

      it "updates event_procedure" do
        attributes = { date: Time.zone.yesterday, payd_at: Time.zone.tomorrow }
        described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(event_procedure.reload.attributes).to include(
          "date" => attributes[:date],
          "payd_at" => attributes[:payd_at]
        )
      end

      it "update event_procedure association 'patient'" do
        attributes = { patient_id: create(:patient, name: "New Patient").id }
        result = described_class.result(id: event_procedure.id.to_s, attributes: attributes)

        expect(result.event_procedure.reload.patient.name).to eq("New Patient")
      end

      it "returns success" do
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
