# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationPolicy do
  let(:user) { create(:user) }
  let(:patient) { create(:patient, user: user) }
  let(:another_owner_patient) { create(:patient) }

  permissions :index?, :show?, :create?, :new?, :update?, :edit?, :destroy? do
    it { expect(described_class).not_to permit(nil, nil) }
  end

  permissions :user_owner? do
    context "when user is owner" do
      it { expect(described_class).to permit(user, patient) }
    end

    context "when user is not owner" do
      it { expect(described_class).not_to permit(user, another_owner_patient) }
    end

    context "when has no user" do
      it { expect(described_class).not_to permit(nil, patient) }
    end
  end

  describe ApplicationPolicy::ApplicationScope do
    subject(:result) { described_class.new(nil, nil).resolve }

    context "when raises error NotImplementedErro" do
      it { expect { result }.to raise_error(NotImplementedError) }
    end
  end
end
