# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::ByHospitalNameQuery do
  describe "#call" do
    context "when a matching hospital name is provided" do
      it "returns filtered event_procedures" do
        regional_norte = create(:hospital, name: "Hospital Regional Norte")
        regional_cariri = create(:hospital, name: "Hospital Regional do Cariri")
        regional_jaguaribe = create(:hospital, name: "Hospital Regional do Vale do Jaguaribe")
        _sao_matheus = create(:hospital, name: "Hospital São Matheus")
        event_procedure_norte = create(:event_procedure, hospital: regional_norte)
        event_procedure_cariri = create(:event_procedure, hospital: regional_cariri)
        event_procedure_jaguaribe = create(:event_procedure, hospital: regional_jaguaribe)

        query = described_class.call(hospital_name: "Regional")

        expect(query).to contain_exactly(event_procedure_norte, event_procedure_cariri, event_procedure_jaguaribe)
      end
    end

    context "when the hospital name is an exact match" do
      it "returns the event_procedure for the exact matching hospital" do
        regional_norte = create(:hospital, name: "Hospital Regional Norte")
        regional_cariri = create(:hospital, name: "Hospital Regional do Cariri")
        _event_procedure_norte = create(:event_procedure, hospital: regional_norte)
        event_procedure_cariri = create(:event_procedure, hospital: regional_cariri)

        query = described_class.call(hospital_name: "Cariri")

        expect(query).to contain_exactly(event_procedure_cariri)
      end
    end

    context "when a hospital name does not match any hospital" do
      it "returns an empty collection" do
        regional_norte = create(:hospital, name: "Hospital Regional Norte")
        regional_cariri = create(:hospital, name: "Hospital Regional do Cariri")
        _event_procedure_norte = create(:event_procedure, hospital: regional_norte)
        _event_procedure_cariri = create(:event_procedure, hospital: regional_cariri)

        query = described_class.call(hospital_name: "São")

        expect(query).to be_empty
      end
    end

    context "when hospital name is nil" do
      it "returns empty collection" do
        create(:hospital, name: "Hospital Regional Norte")
        create(:hospital, name: "Hospital Regional do Cariri")
        create(:hospital, name: "Hospital Regional do Vale do Jaguaribe")

        query = described_class.call(hospital_name: nil)

        expect(query).to be_empty
      end
    end

    context "when keyword arguments are missing" do
      it "raises an ArgumentError" do
        expect { described_class.call }.to raise_error(ArgumentError, "missing keyword: :hospital_name")
      end
    end
  end
end
