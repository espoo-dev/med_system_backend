# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  subject { build(:user) }

  describe "associations" do
    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
    it { is_expected.to have_many(:medical_shifts).dependent(:destroy) }
    it { is_expected.to have_many(:patients).dependent(:destroy) }
    it { is_expected.to have_many(:procedures).dependent(:destroy) }
    it { is_expected.to have_many(:health_insurances).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end
end
