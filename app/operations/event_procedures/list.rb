# frozen_string_literal: true

module EventProcedures
  class List < Actor
    input :scope, type: Enumerable
    input :params, type: Hash, default: -> { {} }

    output :event_procedures, type: Enumerable

    def call
      self.event_procedures = ordered_paginated_query
    end

    private

    def filtered_query
      query = EventProcedures::WithAssociationsQuery.call(relation: scope)
      query = apply_month_filter(query)
      apply_payd_filter(query)
    end

    def ordered_paginated_query
      subquery = filtered_query
      EventProcedure.from(subquery, :event_procedures)
        .order(date: :desc)
        .page(params[:page])
        .per(params[:per_page])
    end

    def apply_month_filter(query)
      params[:month].present? ? query.by_month(month: params[:month]) : query
    end

    def apply_payd_filter(query)
      %w[true false].include?(params[:payd]) ? query.by_payd(payd: params[:payd]) : query
    end
  end
end
