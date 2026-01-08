# frozen_string_literal: true

module Procedures
  class Find < Actor
    input :id, type: String
    input :scope, type: Enumerable, default: -> { Procedure.all }

    output :procedure, type: Procedure

    def call
      self.procedure = scope.find(id)
    end
  end
end
