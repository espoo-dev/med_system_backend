# frozen_string_literal: true

module Procedures
  class Create < Actor
    input :attributes, type: Hash

    output :procedure, type: Procedure

    def call
      self.procedure = Procedure.new(attributes)

      fail!(error: :invalid_record) unless procedure.save
    end
  end
end
