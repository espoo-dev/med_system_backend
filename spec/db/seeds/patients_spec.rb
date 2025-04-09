# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Patients seed" do
  let(:seed_file) { Rails.root.join("db/seeds/07_patients.rb") }

  before do
    create(:user)
  end

  it "runs without errors" do
    expect { load seed_file }.not_to raise_error
  end

  it "creates records in the database" do
    expect(Patient.count).to be(0)

    load seed_file

    expect(Patient.count).to be(1)
  end
end
