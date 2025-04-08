# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Event Procedures seed" do
  let(:seed_file) { Rails.root.join("db/seeds/09_event_procedures.rb") }

  before do
    User.destroy_all
    Patient.destroy_all
    Hospital.destroy_all
    Procedure.destroy_all
    HealthInsurance.destroy_all
    Cbhpm.destroy_all
    EventProcedure.destroy_all

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
    expect { load seed_file }.not_to raise_error
  end

  it "creates records in the database" do
    initial_event_procedures_count = EventProcedure.count

    load seed_file

    expect(EventProcedure.count).to be > initial_event_procedures_count
  end
end
