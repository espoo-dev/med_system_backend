# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedure do
  describe "associations" do
    it { is_expected.to belong_to(:health_insurance) }
    it { is_expected.to belong_to(:hospital) }
    it { is_expected.to belong_to(:patient) }
    it { is_expected.to belong_to(:procedure) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:patient_service_number) }
    it { is_expected.to validate_presence_of(:room_type) }
  end

  describe ".enumerations" do
    it "has enumerations for room_type" do
      expect(described_class.enumerations).to include(room_type: EventProcedures::RoomTypes)
    end
  end
end
