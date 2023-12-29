# frozen_string_literal: true

module Api
  module V1
    class ProceduresController < ApiController
      def index
        procedures = Procedure.page(params[:page]).per(params[:per_page])

        authorize(procedures)

        render json: procedures, status: :ok
      end

      def create
        authorize(Procedure)
        result = Procedures::Create.result(attributes: procedure_params)

        if result.success?
          render json: result.procedure, status: :created
        else
          render json: result.procedure.errors, status: :unprocessable_entity
        end
      end

      private

      def procedure_params
        params.permit(:name, :code, :amount_cents).to_h
      end
    end
  end
end
