# frozen_string_literal: true

module Api
  module V1
    class EventProceduresController < ApiController
      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: :index

      def index
        authorized_scope = policy_scope(EventProcedure)
        listed_event_procedures = EventProcedures::List.result(
          scope: authorized_scope,
          params: event_procedure_permitted_query_params
        )
        event_procedures = listed_event_procedures.event_procedures
        event_procedures_unpaginated = listed_event_procedures.event_procedures_unpaginated

        total_amount_cents = EventProcedures::TotalAmountCents.call(event_procedures: event_procedures_unpaginated)

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
          render json: result.error, status: :unprocessable_entity
        end
      end

      def update
        authorize(event_procedure)
        result = EventProcedures::Update.result(id: event_procedure.id.to_s, attributes: event_procedure_params)

        if result.success?
          render json: result.event_procedure, status: :ok
        else
          render json: result.error, status: :unprocessable_entity
        end
      end

      def destroy
        authorize(event_procedure)
        result = EventProcedures::Destroy.result(id: event_procedure.id.to_s)

        if result.success?
          deleted_successfully_render(result.event_procedure)
        else
          render json: result.error, status: :unprocessable_entity
        end
      end

      private

      def event_procedure_permitted_params
        params.permit(
          :hospital_id,
          :cbhpm_id,
          :patient_service_number,
          :date,
          :urgency,
          :amount_cents,
          :payd,
          :room_type,
          :payment,
          patient_attributes: %i[
            id name
          ],
          procedure_attributes: %i[
            id name code amount_cents description custom
          ],
          health_insurance_attributes: %i[
            id name custom
          ]
        ).to_h
      end

      def event_procedure_permitted_query_params
        params.permit(
          :page,
          :per_page,
          :month,
          :year,
          :payd,
          hospital: [:name],
          health_insurance: [:name]
        ).to_h
      end

      def event_procedure_params
        result_params = event_procedure_permitted_params

        %i[patient_attributes health_insurance_attributes procedure_attributes].each do |attribute|
          result_params[attribute]&.merge!(user_id: current_user.id)
        end

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
