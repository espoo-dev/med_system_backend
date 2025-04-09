# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Custom Procedures seed" do
  subject(:load_seed) { load seed_file }

  let(:seed_file) { Rails.root.join("db/seeds/03_procedures_custom.rb") }

  before do
    create(:user)
  end

  it "runs without errors" do
    expect { load_seed }.not_to raise_error
  end

  it "creates records in the database" do
    expect { load_seed }.to change(Procedure, :count).from(0).to(1)
  end
end
