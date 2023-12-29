# frozen_string_literal: true

module Procedures
  class Find < Actor
    input :id, type: String

    output :procedure, type: Procedure

    def call
      self.procedure = Procedure.find(id)
    end
  end
end
