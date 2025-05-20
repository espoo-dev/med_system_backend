# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedure do
  describe "soft delete behavior" do
    let(:user) { create(:user) }
    let(:patient) { create(:patient, user: user) }
    let(:event_procedure) { create(:event_procedure, user: user, patient: patient) }

    it_behaves_like "acts as paranoid", :event_procedure
  end

  describe "associations" do
    it { is_expected.to belong_to(:cbhpm) }
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

    context "when validating custom and urgency" do
      let(:user) { create(:user) }
      let(:procedure) { build(:procedure, custom: true, user: user) }
      let(:event) { build(:event_procedure, urgency: true, procedure: procedure) }

      it "is invalid when custom and urgency true" do
        expect(event).not_to be_valid
        expect(event.errors[:base]).to include("Custom procedures can't be urgent")
      end

      it "is valid when urgency is false and custom is true" do
        event.urgency = false
        expect(event).to be_valid
      end

      it "is valid when urgency is true and custom is false" do
        event.procedure.custom = false
        expect(event).to be_valid
      end
    end

    context "when patient belongs to a different user" do
      it "is invalid when patient and event_procedure have different users" do
        user = create(:user)
        other_user = create(:user)
        patient = create(:patient, user: other_user)

        event_procedure = build(:event_procedure, user: user, patient: patient)

        expect(event_procedure).not_to be_valid
        expect(event_procedure.errors[:base]).to include("The patient must be associated with the same procedure user")
      end
    end

    context "when patient belongs to the same user" do
      it "is valid when patient and event_procedure have the same user" do
        user = create(:user)
        patient = create(:patient, user: user)
        event_procedure = build(:event_procedure, user: user, patient: patient)

        expect(event_procedure).to be_valid
      end
    end
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
    let(:user) { create(:user) }

    context "when patient_attributes are provided" do
      it "creates patient" do
        event_procedure = build(
          :event_procedure,
          user: user,
          patient: nil,
          patient_attributes: { name: "John Doe", user_id: user.id }
        )

        expect { event_procedure.save }.to change(Patient, :count).by(1)
        expect(event_procedure.patient).to be_persisted
        expect(event_procedure.patient.name).to eq("John Doe")
      end
    end

    context "when patient_attributes are not provided" do
      it "does not create patient" do
        event_procedure = build(
          :event_procedure,
          patient: nil,
          patient_attributes: { name: nil, user_id: nil }
        )

        expect(event_procedure.save).to be_falsey
        expect(event_procedure.errors[:"patient.name"]).to include("can't be blank")
      end
    end
  end

  describe "nested attributes for procedure" do
    context "when procedure_attributes are provided" do
      it "creates procedure" do
        user = create(:user)
        patient = create(:patient, user: user)
        procedure_attributes = {
          id: nil,
          name: "procedure name",
          code: "code-1234",
          amount_cents: 100,
          description: "procedure description",
          custom: true,
          user_id: user.id
        }
        event_procedure = build(
          :event_procedure, user: user, patient: patient,
          procedure_attributes: procedure_attributes
        )

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

  describe "nested attributes for health_insurance" do
    context "when health_insurance_attributes are provided" do
      it "creates health_insurance" do
        user = create(:user)
        patient = create(:patient, user: user)
        health_insurance_attributes = {
          id: nil,
          name: "health_insurance name",
          custom: true,
          user_id: user.id
        }
        event_procedure = build(
          :event_procedure, user: user, patient: patient,
          health_insurance_attributes: health_insurance_attributes
        )

        expect { event_procedure.save }.to change(HealthInsurance, :count).by(1)
        expect(event_procedure.health_insurance).to be_persisted
        expect(event_procedure.health_insurance.name).to eq("health_insurance name")
      end
    end

    context "when health_insurance_attributes are not provided" do
      it "does not create health_insurance" do
        user = create(:user)
        health_insurance_attributes = {
          id: nil,
          name: nil,
          custom: true,
          user_id: user.id
        }
        event_procedure = build(:event_procedure, health_insurance_attributes: health_insurance_attributes)

        expect(event_procedure.save).to be_falsey
        expect(event_procedure.errors[:"health_insurance.name"]).to eq(["can't be blank"])
      end
    end
  end
end
