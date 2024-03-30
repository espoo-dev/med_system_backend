# frozen_string_literal: true

module Procedures
  class FindOrCreate < Actor
    input :params, type: Hash, allow_nil: true

    output :procedure, type: Procedure

    def call
      self.procedure = find_procedure || create_procedure
    end

    private

    def find_procedure
      Procedure.find_by(id: params[:id]) if params[:id]
    end

    def create_procedure
      self.procedure = build_procedure

      fail!(error: :invalid_record) unless procedure.save

      procedure
    end

    def build_procedure
      Procedure.new(
        name: params[:name],
        code: params[:code],
        amount_cents: params[:amount_cents],
        description: params[:description],
        custom: params[:custom],
        user_id: params[:user_id]
      )
    end
  end
end
