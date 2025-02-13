# frozen_string_literal: true

require "rails_helper"

RSpec.describe HealthInsurances::List, type: :operation do
  describe ".result" do
    it "is successful" do
      result = described_class.result

      expect(result).to be_success
    end

    it "returns all health insurances ordered by created_at desc" do
      today_health_insurance = create(:health_insurance, created_at: Time.zone.today)
      tomorrow_health_insurance = create(:health_insurance, created_at: Time.zone.tomorrow)
      yesterday_health_insurance = create(:health_insurance, created_at: Time.zone.yesterday)

      result = described_class.result

      expect(result.health_insurances).to eq(
        [
          tomorrow_health_insurance,
          today_health_insurance,
          yesterday_health_insurance
        ]
      )
    end

    context 'when filtering by user' do
      it 'returns only health insurances for the specified user' do
        user1 = create(:user)
        user2 = create(:user)
        health_insurance_user1 = create(:health_insurance, custom: true, user: user1)
        health_insurance_user2 = create(:health_insurance, custom: true, user: user2)
        
        result_user1 = described_class.call(user: user1)
        expect(result_user1.health_insurances).to all(have_attributes(user: user1))
        expect(result_user1.health_insurances[0].id).to eq(health_insurance_user1.id)

        result_user2 = described_class.call(user: user2)
        expect(result_user2.health_insurances).to all(have_attributes(user: user2))
        expect(result_user2.health_insurances[0].id).to eq(health_insurance_user2.id)
      end

      it 'returns no health insurances for user without any' do
        new_user = create(:user)
        result = described_class.call(user: new_user)
        
        expect(result.health_insurances).to be_empty
      end
    end

    context "when custom is true" do
      it "returns only the custom health_insurances for the given user" do
        user = create(:user)
        another_user = create(:user)
        custom_health_insurance = create(:health_insurance, custom: true, user: user)
        _another_custom_health_insurance = create(:health_insurance, custom: true, user: another_user)
        _non_custom_health_insurance = create(:health_insurance, custom: false)

        result = described_class.result(params: { custom: "true" }, user: user)

        expect(result.health_insurances).to contain_exactly(custom_health_insurance)
      end
    end

    context "when custom is false" do
      it "returns only the non-custom health_insurances" do
        user = create(:user)
        _custom_health_insurance = create(:health_insurance, custom: true, user: user)
        non_custom_health_insurance = create(:health_insurance, custom: false)

        result = described_class.result(params: { custom: "false" }, user: user)

        expect(result.health_insurances).to contain_exactly(non_custom_health_insurance)
      end
    end
  end

  context "when has pagination via page and per_page" do
    it "paginate the health insurances" do
      create_list(:health_insurance, 8)

      result = described_class.result(params: { page: 1, per_page: 5 })

      expect(result.health_insurances.count).to eq 5
    end
  end
end
