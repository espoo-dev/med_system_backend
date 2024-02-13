# frozen_string_literal: true

module HealthInsurances
  class List < Actor
    input :scope, type: Enumerable, default: -> { HealthInsurance.all }
    input :params, type: Hash, default: -> { {} }

    output :health_insurances, type: Enumerable

    def call
      self.health_insurances = scope.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    end
  end
end
