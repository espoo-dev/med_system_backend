# frozen_string_literal: true

module HealthInsurances
  class FindOrCreate < Actor
    input :params, type: Hash, allow_nil: true

    output :health_insurance, type: HealthInsurance

    def call
      self.health_insurance = find_health_insurance || create_health_insurance
    end

    private

    def find_health_insurance
      HealthInsurance.find_by(id: params[:id]) if params[:id]
    end

    def create_health_insurance
      self.health_insurance = build_health_insurance

      fail!(error: :invalid_record) unless health_insurance.save

      health_insurance
    end

    def build_health_insurance
      HealthInsurance.new(
        name: params[:name],
        custom: params[:custom],
        user_id: params[:user_id]
      )
    end
  end
end
