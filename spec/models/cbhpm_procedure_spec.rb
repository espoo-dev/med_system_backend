# frozen_string_literal: true

require "rails_helper"

RSpec.describe CbhpmProcedure do
  describe "associations" do
    it { is_expected.to belong_to(:cbhpm) }
    it { is_expected.to belong_to(:procedure) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:port) }
    it { is_expected.to validate_presence_of(:anesthetic_port) }
  end
end
