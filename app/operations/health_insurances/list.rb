# frozen_string_literal: true

module HealthInsurances
  class List < Actor
    input :scope, type: Enumerable, default: -> { HealthInsurance.all }
    input :params, type: Hash, default: -> { {} }
    input :user, type: User, default: nil

    output :health_insurances, type: Enumerable

    def call
      self.health_insurances = filtered_query.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    end

    private

    def filtered_query
      query = scope
      apply_custom_filter(query)
    end

    def apply_custom_filter(query)
      if %w[true false].include?(params[:custom])
        query.by_custom(custom: params[:custom], user: user)
      else
        query.where(user: user)
      end
    end
  end
end
