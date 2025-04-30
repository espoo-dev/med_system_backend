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
end
