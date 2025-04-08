# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Hospitals seed" do
  let(:seed_file) { Rails.root.join("db/seeds/06_hospitals.rb") }

  before do
    Hospital.destroy_all
  end

  it "runs without errors" do
    expect { load seed_file }.not_to raise_error
  end

  it "creates records in the database" do
    initial_hospital_count = Hospital.count

    load seed_file

    expect(Hospital.count).to be > initial_hospital_count
  end
end
