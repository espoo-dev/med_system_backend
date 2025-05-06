# frozen_string_literal: true

require "rails_helper"

RSpec.describe HospitalPolicy do
  let(:user) { create(:user) }
  let(:hospital) { create(:hospital) }

  describe "permissions" do
    context "when has user" do
      subject { described_class.new(user, hospital) }

      it { is_expected.to permit_actions(%i[index create update destroy]) }
    end

    context "when has no user" do
      subject { described_class.new(nil, hospital) }

      it { is_expected.to forbid_actions(%i[index create update destroy]) }
    end
  end
end
