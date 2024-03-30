# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedure do
  describe "associations" do
    it { is_expected.to belong_to(:health_insurance) }
    it { is_expected.to belong_to(:hospital) }
    it { is_expected.to belong_to(:patient) }
    it { is_expected.to belong_to(:procedure) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:patient_service_number) }
    it { is_expected.to validate_presence_of(:room_type) }
    it { is_expected.to validate_presence_of(:payment) }
  end

  describe ".enumerations" do
    it "has enumerations for room_type" do
      expect(described_class.enumerations).to include(room_type: EventProcedures::RoomTypes)
    end

    it "has enumerations for payment" do
      expect(described_class.enumerations).to include(payment: EventProcedures::Payments)
    end
  end

  describe "monetization" do
    it "monetizes total_amount attribute" do
      event_procedure = described_class.new(total_amount_cents: 10)

      expect(event_procedure.total_amount).to eq Money.new(10, "BRL")
    end
  end

  describe "nested attributes for patient" do
    context "when patient_attributes are provided" do
      it "creates patient" do
        event_procedure = build(:event_procedure, patient_attributes: { id: nil, name: "John Doe" })

        expect { event_procedure.save }.to change(Patient, :count).by(1)
        expect(event_procedure.patient).to be_persisted
        expect(event_procedure.patient.name).to eq("John Doe")
      end
    end

    context "when patient_attributes are not provided" do
      it "does not create patient" do
        event_procedure = build(:event_procedure, patient_attributes: { id: nil, name: nil })

        expect(event_procedure.save).to be_falsey
        expect(event_procedure.errors[:"patient.name"]).to include("can't be blank")
      end
    end
  end

  describe "nested attributes for procedure" do
    context "when procedure_attributes are provided" do
      it "creates procedure" do
        user = create(:user)
        procedure_attributes = {
          id: nil,
          name: "procedure name",
          code: "code-1234",
          amount_cents: 100,
          description: "procedure description",
          custom: true,
          user_id: user.id
        }
        event_procedure = build(:event_procedure, procedure_attributes: procedure_attributes)

        expect { event_procedure.save }.to change(Procedure, :count).by(1)
        expect(event_procedure.procedure).to be_persisted
        expect(event_procedure.procedure.code).to eq("code-1234")
      end
    end

    context "when procedure_attributes are not provided" do
      it "does not create procedure" do # rubocop:disable RSpec/MultipleExpectations
        user = create(:user)
        procedure_attributes = {
          id: nil,
          name: nil,
          code: nil,
          amount_cents: nil,
          description: nil,
          custom: nil,
          user_id: user.id
        }
        event_procedure = build(:event_procedure, procedure_attributes: procedure_attributes)

        expect(event_procedure.save).to be_falsey
        expect(event_procedure.errors[:"procedure.name"]).to eq(["can't be blank"])
        expect(event_procedure.errors[:"procedure.code"]).to eq(["can't be blank"])
        expect(event_procedure.errors[:"procedure.amount_cents"]).to eq(["can't be blank", "is not a number"])
      end
    end
  end
end
