# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Custom Health Insurances seed" do
  let(:seed_file) { Rails.root.join("db/seeds/05_health_insurances_custom.rb") }

  before do
    HealthInsurance.destroy_all
    User.destroy_all
    create(:user)
  end

  it "runs without errors" do
    expect { load seed_file }.not_to raise_error
  end

  it "creates records in the database" do
    initial_health_insurance_count = HealthInsurance.count

    load seed_file

    expect(HealthInsurance.count).to be > initial_health_insurance_count
  end
end
