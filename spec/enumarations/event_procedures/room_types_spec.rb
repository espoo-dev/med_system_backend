# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProcedures::RoomTypes, type: :enumeration do
  describe ".list" do
    it "returns room_types" do
      expect(described_class.list).to eq(%w[ward apartment])
    end
  end
end
