# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Patients seed" do
  let(:seed_file) { Rails.root.join("db/seeds/07_patients.rb") }

  before do
    Patient.destroy_all
    User.destroy_all
    create(:user)
  end

  it "runs without errors" do
    expect { load seed_file }.not_to raise_error
  end

  it "creates records in the database" do
    initial_patients_count = Patient.count

    load seed_file

    expect(Patient.count).to be > initial_patients_count
  end
end
