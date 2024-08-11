# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::ByYearQuery do
  context "when query by year" do
    subject(:result) { described_class.call(year: "2024") }

    let(:event_procedures) { create_list(:event_procedure, 2, date: "2024-01-01") }

    before do
      event_procedures
      EventProcedure.last.update(date: "2023-01-01")
    end

    context "with param year" do
      it { expect(result).to contain_exactly(EventProcedure.first) }
    end

    context "without param year" do
      subject(:result) { described_class.call }

      it { expect { result }.to raise_error(ArgumentError, "missing keyword: :year") }
    end
  end
end
