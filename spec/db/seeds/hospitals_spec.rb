# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Hospitals seed" do
  subject(:load_seed) { load seed_file }

  let(:seed_file) { Rails.root.join("db/seeds/06_hospitals.rb") }

  it "runs without errors" do
    expect { load_seed }.not_to raise_error
  end

  it "creates records in the database" do
    expect { load_seed }.to change(Hospital, :count).from(0).to(1)
  end
end
