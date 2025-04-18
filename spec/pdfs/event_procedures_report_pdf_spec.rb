# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProceduresReportPdf, type: :pdf do
  it "generates a report with the correct content" do
    user = create(:user)
    patient = create(:patient, user: user)
    pdf = Prawn::Document.new
    event_procedures = create_list(:event_procedure, 3, user_id: user.id, patient: patient)
    amount = EventProcedures::TotalAmountCents.call(event_procedures: event_procedures)

    described_class.new(
      pdf: pdf, amount: amount, items: event_procedures, title: "Procedimentos", email: user.email
    ).generate
    rendered_pdf = pdf.render
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)

    event_procedures.each do |event_procedure|
      expect(text_analysis.strings).to include(
        event_procedure.procedure.name,
        event_procedure.procedure.amount.format,
        event_procedure.patient.name,
        "#{event_procedure.hospital.name} - #{event_procedure.health_insurance.name}",
        event_procedure.date.strftime("%d/%m/%Y")
      )
    end
  end
end
