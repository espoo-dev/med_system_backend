# frozen_string_literal: true

module Procedures
  class Create < Actor
    input :attributes, type: Hash
    input :user, type: User, default: nil

    output :procedure, type: Procedure

    def call
      self.procedure = Procedure.new(attributes)
      procedure.user = user if procedure.custom?

      fail!(error: :invalid_record) unless procedure.save
    end
  end
end
