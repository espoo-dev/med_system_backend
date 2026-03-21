# frozen_string_literal: true

module EventProcedures
  class Destroy < Actor
    input :id, type: String
    input :scope, type: Enumerable, default: -> { EventProcedure.all }

    output :event_procedure, type: EventProcedure

    def call
      self.event_procedure = scope.find(id)

      fail!(error: :cannot_destroy) unless event_procedure.destroy
    end
  end
end
