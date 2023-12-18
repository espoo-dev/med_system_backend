# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurance do
  describe "associations" do
    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
