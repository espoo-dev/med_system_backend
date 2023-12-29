# frozen_string_literal: true

module Procedures
  class Update < Actor
    input :id, type: String
    input :attributes, type: Hash

    output :procedure, type: Procedure

    def call
      self.procedure = find_procedure

      fail!(error: :invalid_record) unless procedure.update(attributes)
    end

    private

    def find_procedure
      Procedures::Find.result(id: id).procedure
    end
  end
end
