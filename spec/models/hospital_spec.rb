# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hospital do
  describe "associations" do
    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:hospital) }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:address).case_insensitive }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }
  end
end
