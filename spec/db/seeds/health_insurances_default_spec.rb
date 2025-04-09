# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Default Health Insurances seed" do
  let(:seed_file) { Rails.root.join("db/seeds/04_health_insurances_default.rb") }

  it "runs without errors" do
    expect { load seed_file }.not_to raise_error
  end

  it "creates records in the database" do
    expect(HealthInsurance.count).to be(0)

    load seed_file

    expect(HealthInsurance.count).to be(9)
  end
end
