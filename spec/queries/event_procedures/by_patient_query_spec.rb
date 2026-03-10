# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::ByPatientQuery do
  describe "#call" do
    context "when a matching patient name is provided" do
      it "returns event_procedures for patients matching the name" do
        user = create(:user)
        joao = create(:patient, name: "João Silva", user: user)
        maria = create(:patient, name: "Maria Souza", user: user)
        ep_joao = create(:event_procedure, user: user, patient: joao)
        _ep_maria = create(:event_procedure, user: user, patient: maria)

        query = described_class.call(patient_name: "João")

        expect(query).to contain_exactly(ep_joao)
      end

      it "performs case-insensitive partial matching" do
        user = create(:user)
        patient = create(:patient, name: "Carlos Alberto", user: user)
        ep = create(:event_procedure, user: user, patient: patient)

        query = described_class.call(patient_name: "carlos")

        expect(query).to contain_exactly(ep)
      end
    end

    context "when patient name does not match any patient" do
      it "returns an empty collection" do
        user = create(:user)
        patient = create(:patient, name: "Pedro Lima", user: user)
        create(:event_procedure, user: user, patient: patient)

        query = described_class.call(patient_name: "Zélia")

        expect(query).to be_empty
      end
    end

    context "when keyword arguments are missing" do
      it "raises an ArgumentError" do
        expect { described_class.call }.to raise_error(ArgumentError, "missing keyword: :patient_name")
      end
    end
  end
end
