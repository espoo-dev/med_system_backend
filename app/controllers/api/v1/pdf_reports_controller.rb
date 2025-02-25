# frozen_string_literal: true

module Api
  module V1
    class PdfReportsController < ApiController
      def generate
        authorize :pdf_report, :generate?
        return entity_name_failure_response if params[:entity_name].blank?

        pdf = if permitted_query_params[:entity_name] == "event_procedures"
          event_procedures_pdf
        else
          medical_shifts_pdf
        end

        send_data pdf.render, filename: filename, type: "application/pdf", disposition: disposition
      end

      private

      def disposition
        permitted_query_params[:disposition] || "inline"
      end

      def filename
        "#{Time.zone.now.strftime('%d%m%Y')}_report.pdf"
      end

      def entity_name_failure_response
        render json: { error: "You must inform the `entity_name` parameter" }, status: :bad_request
      end

      def event_procedures_pdf
        authorized_scope = policy_scope(EventProcedure)
        event_procedures = EventProcedures::List.result(
          scope: authorized_scope,
          params: permitted_query_params
        ).event_procedures
        total_amount_cents = EventProcedures::TotalAmountCents.call(total_amount_cents_params)

        PdfGeneratorService.new(
          relation: event_procedures,
          amount: total_amount_cents,
          entity_name: permitted_query_params[:entity_name],
          email: current_user.email
        ).generate_pdf
      end

      def medical_shifts_pdf
        authorized_scope = policy_scope(MedicalShift)
        medical_shifts = MedicalShifts::List.result(
          scope: authorized_scope,
          params: permitted_query_params
        ).medical_shifts
        total_amount_cents = MedicalShifts::TotalAmountCents.call(medical_shifts: medical_shifts)

        PdfGeneratorService.new(
          relation: medical_shifts,
          amount: total_amount_cents,
          entity_name: permitted_query_params[:entity_name],
          email: current_user.email
        ).generate_pdf
      end

      def permitted_query_params
        params.permit(
          :page,
          :per_page,
          :month,
          :year,
          :payd,
          :entity_name,
          :disposition,
          hospital: [:name],
          health_insurance: [:name]
        ).to_h
      end

      def total_amount_cents_params
        {
          user_id: current_user.id,
          month: permitted_query_params[:month],
          year: permitted_query_params[:year]
        }
      end
    end
  end
end
