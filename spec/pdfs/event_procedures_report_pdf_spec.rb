# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventProceduresReportPdf, type: :pdf do
  let(:user) { create(:user) }
  let(:patient) { create(:patient, user: user) }
  let(:event_procedures) { create_list(:event_procedure, 3, user_id: user.id, patient: patient) }
  let(:amount) { EventProcedures::TotalAmountCents.call(event_procedures: event_procedures) }

  it "generates a report with the correct content" do
    pdf = Prawn::Document.new

    described_class.new(
      pdf: pdf, amount: amount, items: event_procedures, title: "Procedimentos", email: user.email
    ).generate
    rendered_pdf = pdf.render
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)

    event_procedures.each do |event_procedure|
      expect(text_analysis.strings).to include(
        event_procedure.procedure.name,
        event_procedure.patient.name,
        "#{event_procedure.hospital.name} - #{event_procedure.health_insurance.name} -
        #{event_procedure.date.strftime('%d/%m/%Y')}".squish
      )
    end
  end

  context "when hide_values is true" do
    it "does not include monetary values in the report" do
      pdf = Prawn::Document.new

      described_class.new(
        pdf: pdf, amount: amount, items: event_procedures, title: "Procedimentos", email: user.email,
        hide_values: true
      ).generate
      rendered_pdf = pdf.render
      text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)

      event_procedures.each do |event_procedure|
        expect(text_analysis.strings).not_to include(
          event_procedure.total_amount.format(thousands_separator: ".", decimal_mark: ",")
        )
      end
      expect(text_analysis.strings).not_to include(amount.total, amount.paid, amount.unpaid)
    end
  end
end
