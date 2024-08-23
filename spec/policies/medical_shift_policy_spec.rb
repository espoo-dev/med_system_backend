# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftPolicy do
  let(:user) { create(:user) }
  let(:medical_shift) { create(:medical_shift, user: user) }
  let(:medical_shift_without_user) { create(:medical_shift) }

  describe "Scope" do
    subject(:result) { instance.resolve }

    let(:instance) { described_class::Scope.new(user, MedicalShift.all) }

    context "when has user" do
      it { expect(result).to eq [medical_shift] }
    end

    context "when has no user" do
      let(:user) { nil }

      it { expect(result).to eq [] }
    end
  end

  permissions :index?, :create? do
    context "when has user" do
      it { expect(described_class).to permit(user, medical_shift) }
    end

    context "when has no user" do
      it { expect(described_class).not_to permit(nil, medical_shift) }
    end
  end

  permissions :update?, :destroy? do
    context "when has user" do
      it { expect(described_class).to permit(user, medical_shift) }
    end

    context "when has no user" do
      it { expect(described_class).not_to permit(nil, medical_shift) }
    end

    context "when user is not owner" do
      it { expect(described_class).not_to permit(user, medical_shift_without_user) }
    end
  end
end
