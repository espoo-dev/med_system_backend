# frozen_string_literal: true

require "rails_helper"

RSpec.describe Patient do
  describe "associations" do
    it { is_expected.to have_many(:event_procedures).dependent(:restrict_with_exception) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "deletable?" do
    subject { patient.deletable? }

    let(:user) { create(:user) }
    let(:patient) { create(:patient, user: user) }

    context "when patient has no event_procedures" do
      it { is_expected.to be_truthy }
    end

    context "when patient has event_procedures" do
      before do
        create(:event_procedure, patient: patient, user: user)
      end

      it { is_expected.to be_falsy }
    end
  end

  describe ".name" do
    let(:patient) { create(:patient, name: "  Patient Name Test  ") }

    context "when patient is created" do
      it { expect(patient.name).to eq("Patient Name Test") }
    end

    context "when patient is updated" do
      before { patient.update(name: "  New Patient Name  ") }

      it { expect(patient.name).to eq("New Patient Name") }
    end
  end
end
