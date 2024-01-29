# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShifts::Workloads, type: :enumeration do
  describe ".list" do
    it "returns workloads" do
      expect(described_class.list).to eq(%w[six twelve twenty_four])
    end
  end
end
