# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::ByHealthInsuranceNameQuery do
  describe "#call" do
    context "when a matching health_insurance name is provided" do
      it "returns filtered event_procedures" do
        amil = create(:health_insurance, name: "Amil")
        sul_america = create(:health_insurance, name: "SulAmérica")
        _sao_camilo = create(:health_insurance, name: "São Camilo")
        event_procedure_sul_america = create(:event_procedure, health_insurance: sul_america)
        event_procedure_amil = create(:event_procedure, health_insurance: amil)

        query = described_class.call(name: "Am")

        expect(query).to contain_exactly(event_procedure_sul_america, event_procedure_amil)
      end
    end

    context "when the health_insurance name is an exact match" do
      it "returns the event_procedure for the exact matching health_insurance" do
        amil = create(:health_insurance, name: "Amil")
        unimed = create(:health_insurance, name: "Unimed")
        event_procedure_amil = create(:event_procedure, health_insurance: amil)
        _event_procedure_unimed = create(:event_procedure, health_insurance: unimed)

        query = described_class.call(name: "Amil")

        expect(query).to contain_exactly(event_procedure_amil)
      end
    end

    context "when a health_insurance name does not match any health_insurance" do
      it "returns an empty collection" do
        amil = create(:health_insurance, name: "Amil")
        unimed = create(:health_insurance, name: "Unimed")
        _event_procedure_amil = create(:event_procedure, health_insurance: amil)
        _event_procedure_unimed = create(:event_procedure, health_insurance: unimed)

        query = described_class.call(name: "São")

        expect(query).to be_empty
      end
    end

    context "when health_insurance name is nil" do
      it "returns empty collection" do
        create(:health_insurance, name: "Amil")
        create(:health_insurance, name: "Unimed")

        query = described_class.call(name: nil)

        expect(query).to be_empty
      end
    end

    context "when keyword arguments are missing" do
      it "raises an ArgumentError" do
        expect { described_class.call }.to raise_error(ArgumentError, "missing keyword: :name")
      end
    end
  end
end
