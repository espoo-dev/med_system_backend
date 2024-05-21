# frozen_string_literal: true

require "rails_helper"

RSpec.describe PortValue do
  describe "associations" do
    it { is_expected.to belong_to(:cbhpm) }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:amount_cents).is_greater_than_or_equal_to(0) }
  end
end
