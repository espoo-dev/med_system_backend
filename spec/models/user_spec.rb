# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  subject { build(:user) }

  describe "associations" do
    it { is_expected.to have_many(:event_procedures).dependent(:destroy) }
    it { is_expected.to have_many(:medical_shifts).dependent(:destroy) }
    it { is_expected.to have_many(:patients).dependent(:destroy) }
    it { is_expected.to have_many(:procedures).dependent(:destroy) }
    it { is_expected.to have_many(:health_insurances).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "confirmations" do
    it "is not confirmed by default" do
      user = create(:user)
      expect(user).not_to be_confirmed
    end

    it "can be confirmed" do
      user = create(:user)
      user.confirm
      expect(user).to be_confirmed
    end

    it "generates a confirmation token" do
      user = create(:user)
      expect(user.confirmation_token).not_to be_nil
    end

    it "do not allow login before confirmation" do
      user = create(:user)
      expect(user).not_to be_active_for_authentication
    end

    it "allows login after confirmation" do
      user = create(:user)
      user.confirm
      expect(user).to be_active_for_authentication
    end
  end

  describe "password reset" do
    let(:user) { create(:user, email: "test@email.com") }

    before do
      user.confirm
    end

    it "sends password reset email" do
      expect { user.send_reset_password_instructions }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "generates reset password token" do
      expect(user.reset_password_token).to be_nil
      user.send_reset_password_instructions
      expect(user.reset_password_token).not_to be_nil
    end

    it "resets password" do
      user.send_reset_password_instructions
      new_password = "new_secure_password"
      user.reset_password(new_password, new_password)
      expect(user.valid_password?(new_password)).to be(true)
    end

    it "clears reset password token after password reset" do
      user.send_reset_password_instructions
      expect(user.reset_password_token).not_to be_nil
      new_password = "new_secure_password"
      user.reset_password(new_password, new_password)
      expect(user.reset_password_token).to be_nil
    end
  end
end
