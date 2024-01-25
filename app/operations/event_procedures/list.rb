# frozen_string_literal: true

module EventProcedures
  class List < Actor
    input :page, type: String, allow_nil: true
    input :per_page, type: String, allow_nil: true
    input :month, type: String, allow_nil: true
    input :payd, type: String, allow_nil: true

    output :event_procedures, type: Enumerable

    def call
      query = EventProcedure.includes(%i[procedure patient hospital health_insurance])

      query = query.where("EXTRACT(MONTH FROM date) = ?", month) if month.present?
      query = filter_by_payd(query)

      self.event_procedures = query.order(created_at: :desc).page(page).per(per_page)
    end

    private

    def filter_by_payd(query)
      return query unless filtered_by_payd?

      payd == "true" ? query.where.not(payd_at: nil) : query.where(payd_at: nil)
    end

    def filtered_by_payd?
      %w[true false].include?(payd)
    end
  end
end
