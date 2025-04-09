# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User seeds" do
  describe "users.rb seed" do
    subject(:load_seed) { load seed_file }

    let(:seed_file) { Rails.root.join("db/seeds/01_users.rb") }

    it "creates user without errors" do
      expect do
        load_seed
      end.not_to raise_error
    end

    it "creates exactly one user" do
      expect { load_seed }.to change(User, :count).by(1)
    end

    it "creates user with correct email" do
      load_seed
      user = User.find_by(email: "user@email.com")
      expect(user).not_to be_nil
    end

    it "creates user with valid password" do
      load_seed
      user = User.find_by(email: "user@email.com")
      expect(user.valid_password?("qwe123")).to be true
    end
  end
end
