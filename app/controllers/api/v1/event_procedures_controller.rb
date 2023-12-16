# frozen_string_literal: true

module Api
  module V1
    class EventProceduresController < ApiController
      def index
        event_procedures = EventProcedure.includes(*EventProcedure::ASSOCIATIONS)
          .page(params[:page]).per(params[:per_page])

        authorize(event_procedures)

        render json: event_procedures, status: :ok
      end
    end
  end
end
