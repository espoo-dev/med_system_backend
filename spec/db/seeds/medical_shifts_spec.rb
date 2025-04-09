# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Medical Shifts seed" do
  subject(:load_seed) { load seed_file }

  let(:seed_file) { Rails.root.join("db/seeds/08_medical_shifts.rb") }

  before do
    create(:hospital)
    create(:user)
  end

  it "runs without errors" do
    expect { load_seed }.not_to raise_error
  end

  it "creates records in the database" do
    expect { load_seed }.to change(MedicalShift, :count).from(0).to(2)
  end
end
