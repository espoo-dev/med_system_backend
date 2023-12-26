# frozen_string_literal: true

module EventProcedures
  class Find < Actor
    input :id, type: String

    output :event_procedure, type: EventProcedure

    def call
      self.event_procedure = EventProcedure.find(id)
    end
  end
end
