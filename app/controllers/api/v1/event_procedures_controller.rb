# frozen_string_literal: true

module Api
  module V1
    class EventProceduresController < ApiController
      def index
        event_procedures = EventProcedure.includes(:procedure, :patient, :hospital, :health_insurance)
          .page(params[:page]).per(params[:per_page])

        authorize(event_procedures)

        render json: event_procedures, status: :ok
      end

      def create
        authorize(EventProcedure)

        result = EventProcedures::Create.result(attributes: event_procedure_params)

        if result.success?
          render json: result.event_procedure, status: :created
        else
          render json: result.errors, status: :unprocessable_entity
        end
      end

      private

      def event_procedure_params
        params.permit(
          :procedure_id,
          :patient_id,
          :hospital_id,
          :health_insurance_id,
          :patient_service_number,
          :date,
          :urgency,
          :amount_cents,
          :payd_at,
          :room_type
        ).to_h
      end
    end
  end
end
