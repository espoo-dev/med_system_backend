# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Medical Shifts seed" do
  let(:seed_file) { Rails.root.join("db/seeds/08_medical_shifts.rb") }

  before do
    create(:hospital)
    create(:user)
  end

  it "runs without errors" do
    expect { load seed_file }.not_to raise_error
  end

  it "creates records in the database" do
    initial_medical_shift_count = MedicalShift.count

    load seed_file

    expect(MedicalShift.count).to be > initial_medical_shift_count
  end
end
