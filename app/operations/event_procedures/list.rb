# frozen_string_literal: true

module EventProcedures
  class List < Actor
    input :page, type: String, allow_nil: true
    input :per_page, type: String, allow_nil: true

    output :event_procedures, type: Enumerable

    def call
      self.event_procedures = EventProcedure.page(page).per(per_page)
    end
  end
end
