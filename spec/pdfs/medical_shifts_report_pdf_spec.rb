# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftsReportPdf, type: :pdf do
  it "generates a report with the correct content" do
    user = create(:user)
    pdf = Prawn::Document.new
    medical_shifts = create_list(:medical_shift, 20, user_id: user.id)
    amount = MedicalShifts::TotalAmountCents.call(medical_shifts: medical_shifts)

    described_class.new(pdf: pdf, amount: amount, items: medical_shifts, title: "Plantões", email: user.email).generate
    rendered_pdf = pdf.render
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)

    medical_shifts.each do |medical_shift|
      expect(text_analysis.strings).to include(
        medical_shift.hospital_name,
        medical_shift.amount.format,
        medical_shift.start_date.strftime("%d/%m/%Y")
      )
    end
  end
end
