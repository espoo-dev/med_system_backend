# frozen_string_literal: true

module Procedures
  class Destroy < Actor
    input :id, type: String

    output :procedure, type: Procedure

    def call
      self.procedure = Procedure.find(id)

      fail!(error: :cannot_destroy) unless procedure.destroy
    end
  end
end
