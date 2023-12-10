# frozen_string_literal: true

require "rails_helper"

RSpec.describe Patient do
  subject { build(:patient) }

  it { is_expected.to validate_presence_of(:name) }
end
