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

      def update
        authorize(procedure)
        result = Procedures::Update.result(id: procedure.id.to_s, attributes: procedure_params)

        if result.success?
          render json: result.procedure, status: :ok
        else
          render json: result.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize(procedure)
        result = Procedures::Destroy.result(id: procedure.id.to_s)

        if result.success?
          render json: result.procedure, status: :ok
        else
          render json: result.errors, status: :unprocessable_entity
        end
      end

      private

      def procedure
        @procedure ||= Procedures::Find.result(id: params[:id]).procedure
      end

      def procedure_params
        params.permit(:name, :code, :amount_cents).to_h
      end
    end
  end
end
