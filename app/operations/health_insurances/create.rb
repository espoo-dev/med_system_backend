# frozen_string_literal: true

module HealthInsurances
  class Create < Actor
    input :attributes, type: Hash
    input :user, type: User, default: nil

    output :health_insurance, type: HealthInsurance

    def call
      self.health_insurance = HealthInsurance.new(attributes)
      health_insurance.user = user if health_insurance.custom?

      fail!(error: :invalid_record) unless health_insurance.save
    end
  end
end
