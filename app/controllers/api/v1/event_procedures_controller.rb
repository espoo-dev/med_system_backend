# frozen_string_literal: true

module Api
  module V1
    class EventProceduresController < ApiController
      def index
        result = EventProcedures::List.result(page: params[:page], per_page: params[:per_page])
        event_procedures = result.event_procedures

        authorize(event_procedures)

        render json: {
          event_procedures: event_procedures,
          total: total_amount_cents[:total],
          total_payd: total_amount_cents[:total_payd],
          total_unpayd: total_amount_cents[:total_unpayd]
        }, status: :ok
      end

      def create
        authorize(EventProcedure)

        result = EventProcedures::Create.result(attributes: event_procedure_params)

        if result.success?
          render json: result.event_procedure, status: :created
        else
          render json: result.event_procedure.errors, status: :unprocessable_entity
        end
      end

      def update
        authorize(event_procedure)
        result = EventProcedures::Update.result(id: event_procedure.id.to_s, attributes: event_procedure_params)

        if result.success?
          render json: result.event_procedure, status: :ok
        else
          render json: result.event_procedure.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize(event_procedure)
        result = EventProcedures::Destroy.result(id: event_procedure.id.to_s)

        if result.success?
          render json: result.event_procedure, status: :ok
        else
          render json: result.error, status: :unprocessable_entity
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

      def event_procedure
        @event_procedure ||= EventProcedures::Find.result(id: params[:id]).event_procedure
      end

      def total_amount_cents
        {
          total: EventProcedures::CalculateTotalAmount.call.total,
          total_payd: EventProcedures::CalculateTotalAmountPayd.call.payd,
          total_unpayd: EventProcedures::CalculateTotalAmountUnpayd.call.unpayd
        }
      end
    end
  end
end
