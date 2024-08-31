# frozen_string_literal: true

module EventProcedures
  class List < Actor
    input :scope, type: Enumerable
    input :params, type: Hash, default: -> { {} }

    output :event_procedures, type: Enumerable

    def call
      self.event_procedures = filtered_query.order(date: :desc).page(params[:page]).per(params[:per_page])
    end

    private

    def filtered_query
      query = scope.includes(%i[procedure patient hospital health_insurance])
      query = apply_month_filter(query)
      query = apply_year_filter(query)
      apply_payd_filter(query)
    end

    def apply_month_filter(query)
      params[:month].present? ? query.by_month(month: params[:month]) : query
    end

    def apply_year_filter(query)
      params[:year].present? ? query.by_year(year: params[:year]) : query
    end

    def apply_payd_filter(query)
      %w[true false].include?(params[:payd]) ? query.by_payd(payd: params[:payd]) : query
    end
  end
end
