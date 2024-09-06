# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MedicalShifts::HospitalNameSuggestion, type: :operation do
  describe '#call' do
    context 'when there are no names stored' do
      it 'returns an empty list' do
        result = described_class.call

        expect(result.names).to be_empty
      end
    end

    context 'when there are names stored' do
      before do
        FactoryBot.create(:medical_shift, hospital_name: 'City Hospital')
        FactoryBot.create(:medical_shift, hospital_name: 'County Hospital')
        FactoryBot.create(:medical_shift, hospital_name: 'City Hospital') # Duplicate name
      end

      it 'returns unique names' do
        result = described_class.call

        expected_names = ['City Hospital', 'County Hospital']
        expect(result.names).to match_array(expected_names)
      end
    end
  end
end
