# frozen_string_literal: true

require "rails_helper"

RSpec.describe Patient do
  describe "associations" do
    it { is_expected.to have_many(:event_procedures).dependent(:restrict_with_exception) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "deletable?" do
    subject { patient.deletable? }

    let(:patient) { create(:patient, event_procedures:) }

    context "when patient has no event_procedures" do
      let(:event_procedures) { [] }

      it { is_expected.to be_truthy }
    end

    context "when patient has event_procedures" do
      let(:event_procedures) { create_list(:event_procedure, 1) }

      it { is_expected.to be_falsy }
    end
  end
end
