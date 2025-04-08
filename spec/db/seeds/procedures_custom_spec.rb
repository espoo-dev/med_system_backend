# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Custom Procedures seed" do
  let(:seed_file) { Rails.root.join("db/seeds/03_procedures_custom.rb") }

  before do
    Procedure.destroy_all
    User.destroy_all
    create(:user)
  end

  it "runs without errors" do
    expect { load seed_file }.not_to raise_error
  end

  it "creates records in the database" do
    initial_procedure_count = Procedure.count

    load seed_file

    expect(Procedure.count).to be > initial_procedure_count
  end
end
