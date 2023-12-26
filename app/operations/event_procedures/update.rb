# frozen_string_literal: true

module EventProcedures
  class Update < Actor
    input :id, type: String
    input :attributes, type: Hash

    output :event_procedure, type: EventProcedure

    def call
      self.event_procedure = find_event_procedure

      fail!(error: :invalid_record) unless event_procedure.update(attributes)
    end

    private

    def find_event_procedure
      EventProcedures::Find.result(id: id).event_procedure
    end
  end
end
