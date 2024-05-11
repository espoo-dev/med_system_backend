# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cbhpm do
  describe "associations" do
    it { is_expected.to have_many(:port_values).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
