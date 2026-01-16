# frozen_string_literal: true

module Api
  module V1
    class ProceduresController < ApiController
      def index
        procedures = Procedures::List.result(
          params: params.permit(:page, :per_page, :custom).to_h,
          user: current_user
        ).procedures

        authorize(procedures)

        render json: procedures, status: :ok
      end

      def create
        authorize(Procedure)
        result = Procedures::Create.result(attributes: procedure_params, user: current_user)

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
          render json: result.procedure.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize(procedure)
        result = Procedures::Destroy.result(id: procedure.id.to_s)

        if result.success?
          deleted_successfully_render(result.procedure)
        else
          render json: result.error, status: :unprocessable_entity
        end
      end

      private

      def procedure
        @procedure ||= Procedures::Find.result(
          id: params[:id],
          scope: policy_scope(Procedure)
        ).procedure
      end

      def procedure_params
        params.permit(:name, :code, :amount_cents, :custom).to_h
      end
    end
  end
end
