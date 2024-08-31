# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::ByYearQuery do
  context "when query by year" do
    subject(:result) { described_class.call(year: "2024") }

    let(:medical_shifts) { create_list(:medical_shift, 2, start_date: "2024-01-01") }

    before do
      medical_shifts
      MedicalShift.last.update(start_date: "2023-01-01")
    end

    context "with param year" do
      it { expect(result).to contain_exactly(MedicalShift.first) }
    end

    context "without param year" do
      subject(:result) { described_class.call }

      it { expect { result }.to raise_error(ArgumentError, "missing keyword: :year") }
    end
  end
end
