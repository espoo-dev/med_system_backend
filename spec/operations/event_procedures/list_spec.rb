# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::List, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.result(page: nil, per_page: nil)

      expect(result.success?).to be true
    end

    it "returns event_procedures ordered by created_at desc" do
      today_event = create(:event_procedure, created_at: Time.zone.today)
      yesterday_event = create(:event_procedure, created_at: Time.zone.yesterday)
      tomorrow_event = create(:event_procedure, created_at: Time.zone.tomorrow)

      result = described_class.result(page: nil, per_page: nil)

      expect(result.event_procedures).to eq [tomorrow_event, today_event, yesterday_event]
    end

    it "includes the associations" do # rubocop:disable RSpec/MultipleExpectations
      procedure = create(:procedure, name: "Tireoidectomia")
      patient = create(:patient, name: "John Doe")
      hospital = create(:hospital, name: "General Hospital")
      health_insurance = create(:health_insurance, name: "Insurance Corp")
      create_list(
        :event_procedure, 3,
        procedure: procedure,
        patient: patient,
        hospital: hospital,
        health_insurance: health_insurance
      )

      result = described_class.result(page: nil, per_page: nil)

      expect(result.event_procedures.first.procedure.name).to eq "Tireoidectomia"
      expect(result.event_procedures.first.patient.name).to eq "John Doe"
      expect(result.event_procedures.first.hospital.name).to eq "General Hospital"
      expect(result.event_procedures.first.health_insurance.name).to eq "Insurance Corp"
    end

    context "when has pagination via page and per_page" do
      it "paginates event_procedures" do
        create_list(:event_procedure, 8)
        result = described_class.result(page: "1", per_page: "5")

        expect(result.event_procedures.count).to eq 5
      end
    end
  end
end
