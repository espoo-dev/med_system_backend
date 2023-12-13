# frozen_string_literal: true

module Api
  module V1
    class ProceduresController < ApiController
      def index
        procedures = Procedure.page(params[:page]).per(params[:per_page])

        authorize(procedures)

        render json: procedures, status: :ok
      end
    end
  end
end
