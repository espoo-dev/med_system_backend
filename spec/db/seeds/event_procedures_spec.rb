# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Event Procedures seed" do
  subject(:load_seed) { load seed_file }

  let(:seed_file) { Rails.root.join("db/seeds/09_event_procedures.rb") }

  before do
    user = create(:user)
    create(:patient, user: user)
    create(:hospital)
    create(:procedure, custom: false)
    create(:procedure, custom: true, user: user)
    create(:health_insurance, custom: false)
    create(:health_insurance, custom: true, user: user)
    create(:cbhpm)
  end

  it "runs without errors" do
    expect { load_seed }.not_to raise_error
  end

  it "creates records in the database" do
    expect { load_seed }.to change(EventProcedure, :count).from(0).to(15)
  end
end
