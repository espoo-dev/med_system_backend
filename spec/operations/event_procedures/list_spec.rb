# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::List, type: :operation do
  describe ".result" do
    it "is successful" do
      user = create(:user)
      result = described_class.result(page: nil, per_page: nil, month: nil, payd: nil, user_id: user.id)

      expect(result.success?).to be true
    end

    it "returns event_procedures ordered by created_at desc" do
      user = create(:user)
      today_event = create(:event_procedure, created_at: Time.zone.today, user: user)
      yesterday_event = create(:event_procedure, created_at: Time.zone.yesterday, user: user)
      tomorrow_event = create(:event_procedure, created_at: Time.zone.tomorrow, user: user)

      result = described_class.result(page: nil, per_page: nil, month: nil, payd: nil, user_id: user.id)

      expect(result.event_procedures).to eq [tomorrow_event, today_event, yesterday_event]
    end

    it "includes the associations" do # rubocop:disable RSpec/MultipleExpectations
      user = create(:user)
      procedure = create(:procedure, name: "Tireoidectomia")
      patient = create(:patient, name: "John Doe")
      hospital = create(:hospital, name: "General Hospital")
      health_insurance = create(:health_insurance, name: "Insurance Corp")
      create_list(
        :event_procedure, 3,
        procedure: procedure,
        patient: patient,
        hospital: hospital,
        health_insurance: health_insurance,
        user: user
      )

      result = described_class.result(page: nil, per_page: nil, month: nil, payd: nil, user_id: user.id)

      expect(result.event_procedures.first.procedure.name).to eq "Tireoidectomia"
      expect(result.event_procedures.first.patient.name).to eq "John Doe"
      expect(result.event_procedures.first.hospital.name).to eq "General Hospital"
      expect(result.event_procedures.first.health_insurance.name).to eq "Insurance Corp"
    end

    context "when has filters by month" do
      it "returns event_procedures per month" do
        user = create(:user)
        month_2_event_procedure = create(:event_procedure, date: "2023-02-15", user: user)
        _month_5_event_procedure = create(:event_procedure, date: "2023-05-26", user: user)

        result = described_class.result(page: nil, per_page: nil, month: "2", payd: nil, user_id: user.id)

        expect(result.event_procedures).to eq [month_2_event_procedure]
      end
    end

    context "when has filters by payd" do
      it "returns paid event_procedures" do
        user = create(:user)
        payd_event_procedures = create_list(:event_procedure, 3, payd_at: "2023-03-15", user: user)
        _unpayd_event_procedures = create_list(:event_procedure, 3, payd_at: nil, user: user)

        result = described_class.result(page: nil, per_page: nil, month: nil, payd: "true", user_id: user.id)

        expect(result.event_procedures.to_a).to match_array(payd_event_procedures)
      end

      it "returns unpaid event_procedures" do
        user = create(:user)
        _payd_event_procedures = create_list(:event_procedure, 3, payd_at: "2023-03-15", user: user)
        unpayd_event_procedures = create_list(:event_procedure, 3, payd_at: nil, user: user)

        result = described_class.result(page: nil, per_page: nil, month: nil, payd: "false", user_id: user.id)

        expect(result.event_procedures.to_a).to match_array(unpayd_event_procedures)
      end
    end

    context "when has pagination via page and per_page" do
      it "paginates event_procedures" do
        user = create(:user)
        create_list(:event_procedure, 8, user: user)
        result = described_class.result(page: "1", per_page: "5", month: nil, payd: nil, user_id: user.id)

        expect(result.event_procedures.count).to eq 5
      end
    end
  end
end
