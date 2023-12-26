# frozen_string_literal: true

module EventProcedures
  class Create < Actor
    input :attributes, type: Hash

    output :event_procedure, type: EventProcedure

    def call
      self.event_procedure = EventProcedure.new(attributes)

      fail!(error: event_procedure.errors) unless event_procedure.save
    end
  end
end
