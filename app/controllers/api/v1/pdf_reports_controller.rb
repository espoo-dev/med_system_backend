# frozen_string_literal: true

module Api
  module V1
    class PdfReportsController < ApiController
      def generate
        authorize :pdf_report, :generate?
        pdf = Prawn::Document.new do
          text "Mock PDF para Testes"
          move_down 10
          text "Data de Geração: #{Time.zone.now.strftime('%d/%m/%Y %H:%M:%S')}"
        end

        disposition = params[:disposition] || "inline"

        send_data pdf.render, filename: "mock_report.pdf", type: "application/pdf", disposition: disposition
      end
    end
  end
end
