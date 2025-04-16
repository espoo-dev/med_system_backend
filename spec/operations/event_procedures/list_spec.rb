# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::List, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.result(scope: EventProcedure.all, params: {})

      expect(result.success?).to be true
    end

    it "returns event_procedures ordered by date desc" do
      user = create(:user)
      today_event = create(:event_procedure, date: Time.zone.today, user: user)
      yesterday_event = create(:event_procedure, date: Time.zone.yesterday, user: user)
      tomorrow_event = create(:event_procedure, date: Time.zone.tomorrow, user: user)

      result = described_class.result(scope: EventProcedure.all, params: {})

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

      result = described_class.result(scope: EventProcedure.all, params: {})

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

        result = described_class.result(scope: EventProcedure.all, params: { month: "2" })

        expect(result.event_procedures).to eq [month_2_event_procedure]
      end
    end

    context "when has filters by paid" do
      it "returns paid event_procedures" do
        user = create(:user)
        paid_event_procedures = create_list(:event_procedure, 3, paid: true, user: user)
        _unpaid_event_procedures = create_list(:event_procedure, 3, paid: false, user: user)

        result = described_class.result(scope: EventProcedure.all, params: { paid: "true" })

        expect(result.event_procedures.to_a).to match_array(paid_event_procedures)
      end

      it "returns unpaid event_procedures" do
        user = create(:user)
        _paid_event_procedures = create_list(:event_procedure, 3, paid: true, user: user)
        unpaid_event_procedures = create_list(:event_procedure, 3, paid: false, user: user)

        result = described_class.result(scope: EventProcedure.all, params: { paid: "false" })

        expect(result.event_procedures.to_a).to match_array(unpaid_event_procedures)
      end
    end

    context "when has pagination via page and per_page" do
      it "paginates event_procedures" do
        user = create(:user)
        create_list(:event_procedure, 8, user: user)
        result = described_class.result(
          scope: EventProcedure.all,
          params: { page: "1", per_page: "5" }
        )

        expect(result.event_procedures.count).to eq 5
      end
    end

    context "when there is filter by year" do
      subject(:result) { described_class.result(scope: EventProcedure.all, params: { year: "2023" }) }

      let(:event_procedures) { create_list(:event_procedure, 2, date: "2024-01-01") }

      before do
        event_procedures
        EventProcedure.last.update(date: "2023-01-01")
      end

      it { expect(result.event_procedures).to eq [EventProcedure.last] }
    end

    describe "event_procedures_unpaginated" do
      context "when there are event procedures outside of pagination" do
        let!(:event_procedures) { create_list(:event_procedure, 11) }

        it "returns all event procedures" do
          result = described_class.result(
            scope: EventProcedure.all,
            params: { page: "1", per_page: "5" }
          )
          event_procedures_paginated = result.event_procedures
          event_procedures_unpaginated = result.event_procedures_unpaginated
          expect(event_procedures_unpaginated).to match_array(event_procedures)
          expect(event_procedures_paginated.count).to eq(5)
        end
      end
    end
  end
end
