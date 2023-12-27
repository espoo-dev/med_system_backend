# frozen_string_literal: true

module EventProcedures
  class Destroy < Actor
    input :id, type: String

    output :event_procedure, type: EventProcedure

    def call
      self.event_procedure = EventProcedure.find(id)

      fail!(error: :cannot_destroy) unless event_procedure.destroy
    end
  end
end
