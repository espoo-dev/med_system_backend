# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MedicalShifts::HospitalNameSuggestion, type: :operation do
  describe '#call' do
    context 'when there are no names stored' do
      let(:user) { create(:user) }

      it 'returns an empty list' do
        result = described_class.result(user_id: user.id)

        expect(result.names).to be_empty
      end
    end

    context 'when there are names stored' do
      let(:user) { create(:user) }
      let(:another_user) { create(:user) }

      before do
        FactoryBot.create(:medical_shift, user: user, hospital_name: 'City Hospital')
        FactoryBot.create(:medical_shift, user: user, hospital_name: 'County Hospital')
        FactoryBot.create(:medical_shift, user: user, hospital_name: 'City Hospital') # Duplicate name
        FactoryBot.create(:medical_shift, user: another_user, hospital_name: 'City Hospital Two')
      end

      it 'returns unique names' do
        result = described_class.result(user_id: user.id)

        expected_names = ['City Hospital', 'County Hospital']
        expect(result.names).to match_array(expected_names)
      end
    end
  end
end
