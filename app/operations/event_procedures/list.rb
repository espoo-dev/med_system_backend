# frozen_string_literal: true

module EventProcedures
  class List < Actor
    input :scope, type: Enumerable
    input :params, type: Hash, default: -> { {} }

    output :event_procedures, type: Enumerable
    output :event_procedures_unpaginated, type: Enumerable

    def call
      self.event_procedures_unpaginated = filtered_query.order(date: :desc)
      self.event_procedures = event_procedures_unpaginated.page(params[:page]).per(params[:per_page])
    end

    private

    def filtered_query
      query = scope.includes(
        :procedure,
        :patient,
        :hospital,
        :health_insurance,
        cbhpm: :port_values
      )
      apply_all_filters(query)
    end

    def apply_all_filters(query)
      query = apply_month_filter(query)
      query = apply_year_filter(query)
      query = apply_hospital_filter(query)
      query = apply_health_insurance_filter(query)
      apply_paid_filter(query)
    end

    def apply_month_filter(query)
      params[:month].present? ? query.by_month(month: params[:month]) : query
    end

    def apply_year_filter(query)
      params[:year].present? ? query.by_year(year: params[:year]) : query
    end

    def apply_paid_filter(query)
      %w[true false].include?(params[:paid]) ? query.by_paid(paid: params[:paid]) : query
    end

    def apply_hospital_filter(query)
      params.dig(:hospital, :name).present? ? query.by_hospital_name(hospital_name: params[:hospital][:name]) : query
    end

    def apply_health_insurance_filter(query)
      if params.dig(:health_insurance, :name).present?
        query.by_health_insurance_name(name: params[:health_insurance][:name])
      else
        query
      end
    end
  end
end
