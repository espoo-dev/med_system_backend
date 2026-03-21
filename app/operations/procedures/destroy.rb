# frozen_string_literal: true

module Procedures
  class Destroy < Actor
    input :id, type: String
    input :scope, type: Enumerable, default: -> { Procedure.all }

    output :procedure, type: Procedure

    def call
      self.procedure = scope.find(id)

      fail!(error: :cannot_destroy) unless procedure.destroy
    end
  end
end
