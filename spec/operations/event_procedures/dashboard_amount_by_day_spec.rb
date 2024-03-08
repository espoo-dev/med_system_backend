# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::DashboardAmountByDay, type: :operation do
  describe ".result" do
    let(:result) { described_class.result(start_date: "01/06/2000", end_date: "05/06/2000") }

    let(:year) { 2000 }
    let(:month) { 6 }
    let(:start_date) { DateTime.new(year, month, 1) }
    let(:end_date) { DateTime.new(year, month, 5) }

    before do
      # out of range
      create_list(:event_procedure, 1, date: start_date - 1.day)
      # included on range
      create_list(:event_procedure, 2, date: start_date)
      create_list(:event_procedure, 3, date: start_date + 1.day)
      create_list(:event_procedure, 4, date: end_date)
      # out of range
      create_list(:event_procedure, 5, date: end_date + 1.day)
    end

    it { expect(result).to be_success }

    it "returns days" do
      expect(result.dashboard_data[:days]).to eq(
        { "01/06/2000" => 2,
          "02/06/2000" => 3,
          "03/06/2000" => 0,
          "04/06/2000" => 0,
          "05/06/2000" => 4 }
      )
    end

    it "returns start_data" do
      expect(result.dashboard_data[:start_date]).to eq("01/06/2000")
    end

    it "returns end_data" do
      expect(result.dashboard_data[:end_date]).to eq(end_date.strftime("05/06/2000"))
    end

    it "returns events_amount" do
      expect(result.dashboard_data[:events_amount]).to eq(9)
    end
  end
end
