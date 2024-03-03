# frozen_string_literal: true

module Api
  module V1
    class EventProceduresController < ApiController
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      def index
        authorized_scope = policy_scope(EventProcedure)
        event_procedures = EventProcedures::List.result(
          scope: authorized_scope,
          params: params.permit(:page, :per_page, :month, :payd).to_h
        ).event_procedures

        total_amount_cents = EventProcedures::TotalAmountCents.call(user_id: current_user.id)

        render json: {
          total: total_amount_cents.total,
          total_payd: total_amount_cents.payd,
          total_unpayd: total_amount_cents.unpaid,
          event_procedures: serialized_event_procedures(event_procedures)
        }, status: :ok
      end

      def create
        authorize(EventProcedure)

        result = EventProcedures::Create.result(attributes: event_procedure_params, user_id: current_user.id)

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

      def event_procedure_permitted_params
        params.permit(
          :procedure_id,
          :hospital_id,
          :health_insurance_id,
          :patient_service_number,
          :date,
          :urgency,
          :amount_cents,
          :payd_at,
          :room_type,
          patient_attributes: %i[id name]
        ).to_h
      end

      def event_procedure_params
        result_params = event_procedure_permitted_params
        result_params[:patient_attributes]&.merge!(user_id: current_user.id)
        result_params
      end

      def event_procedure
        @event_procedure ||= EventProcedures::Find.result(id: params[:id]).event_procedure
      end

      def serialized_event_procedures(event_procedures)
        ActiveModelSerializers::SerializableResource.new(
          event_procedures,
          each_serializer: EventProcedureSerializer
        )
      end
    end
  end
end
