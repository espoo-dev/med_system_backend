# frozen_string_literal: true

module EventProcedures
  class List < Actor
    input :page, type: String, allow_nil: true
    input :per_page, type: String, allow_nil: true
    input :month, type: String, allow_nil: true
    input :payd, type: String, allow_nil: true
    input :user_id, type: Integer

    output :event_procedures, type: Enumerable

    def call
      self.event_procedures = filtered_query.order(created_at: :desc).page(page).per(per_page)
    end

    private

    def filtered_query
      query = EventProcedure.includes(%i[procedure patient hospital health_insurance]).where(user_id: user_id)
      query = apply_month_filter(query)
      apply_payd_filter(query)
    end

    def apply_month_filter(query)
      month.present? ? query.by_month(month: month) : query
    end

    def apply_payd_filter(query)
      %w[true false].include?(payd) ? query.by_payd(payd: payd) : query
    end
  end
end
