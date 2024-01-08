# frozen_string_literal: true

module HealthInsurances
  class Create < Actor
    input :attributes, type: Hash

    output :health_insurance, type: HealthInsurance

    def call
      self.health_insurance = HealthInsurance.new(attributes)

      fail!(error: :invalid_record) unless health_insurance.save
    end
  end
end
