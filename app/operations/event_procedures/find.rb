# frozen_string_literal: true

module EventProcedures
  class Find < Actor
    input :id, type: String
    input :scope, type: Enumerable, default: -> { EventProcedure.all }

    output :event_procedure, type: EventProcedure

    def call
      self.event_procedure = scope.find(id)
    end
  end
end
