# frozen_string_literal: true

require "rails_helper"

RSpec.describe Cbhpm do
  describe "validations" do
    it { is_expected.to validate_presence_of(:year) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
