# frozen_string_literal: true

require "rails_helper"

RSpec.describe FooterPdf, type: :pdf do
  it "generates a footer with the correct content" do
    user = create(:user)
    patient = create(:patient, user: user)
    event_procedures = create_list(:event_procedure, 3, user_id: user.id, patient: patient)
    total_amount_cents = EventProcedures::TotalAmountCents.call(
      event_procedures: event_procedures
    )
    pdf = Prawn::Document.new

    described_class.new(pdf: pdf, amount: total_amount_cents).generate
    rendered_pdf = pdf.render
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)

    expect(text_analysis.strings).to include("Total", total_amount_cents.total)
    expect(text_analysis.strings).to include("A Receber", total_amount_cents.unpaid)
    expect(text_analysis.strings).to include("Recebidos", total_amount_cents.paid)
  end
end
