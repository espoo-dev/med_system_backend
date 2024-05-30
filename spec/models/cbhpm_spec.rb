# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cbhpm do
  describe "associations" do
    it { is_expected.to have_many(:cbhpm_procedures).dependent(:destroy) }
    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
    it { is_expected.to have_many(:port_values).dependent(:destroy) }
    it { is_expected.to have_many(:procedures).through(:cbhpm_procedures) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
