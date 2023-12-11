# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurance do
  subject { build(:health_insurance) }

  it { is_expected.to validate_presence_of(:name) }
end
