# frozen_string_literal: true

require "rails_helper"

RSpec.describe MedicalShiftsReportPdf, type: :pdf do
  let(:user) { create(:user) }
  let(:medical_shifts) { create_list(:medical_shift, 3, user_id: user.id) }
  let(:amount) { MedicalShifts::TotalAmountCents.call(medical_shifts: medical_shifts) }

  it "generates a report with the correct content" do
    pdf = Prawn::Document.new

    described_class.new(pdf: pdf, amount: amount, items: medical_shifts, title: "Plantões", email: user.email).generate
    rendered_pdf = pdf.render
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)

    medical_shifts.each do |medical_shift|
      expect(text_analysis.strings).to include(
        medical_shift.hospital_name,
        medical_shift.amount.format(thousands_separator: ".", decimal_mark: ","),
        medical_shift.start_date.strftime("%d/%m/%Y")
      )
    end
  end

  context "when hide_values is true" do
    it "does not include monetary values in the report" do
      pdf = Prawn::Document.new

      described_class.new(
        pdf: pdf, amount: amount, items: medical_shifts, title: "Plantões", email: user.email, hide_values: true
      ).generate
      rendered_pdf = pdf.render
      text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)

      medical_shifts.each do |medical_shift|
        expect(text_analysis.strings).not_to include(
          medical_shift.amount.format(thousands_separator: ".", decimal_mark: ",")
        )
      end
      expect(text_analysis.strings).not_to include(amount.total, amount.paid, amount.unpaid)
    end
  end
end
