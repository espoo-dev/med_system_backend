# frozen_string_literal: true

require "rails_helper"

RSpec.describe PdfGeneratorService, type: :service do
  describe "#generate_pdf" do
    context "when entity_name is event_procedures" do
      it "generates event_procedures pdf" do
        user = create(:user)
        event_procedures = create_list(:event_procedure, 11)
        amount = EventProcedures::TotalAmountCents.call(user_id: event_procedures.first.user_id, month: nil, year: nil)
        pdf = described_class.new(
          relation: event_procedures, amount: amount, entity_name: "event_procedures", email: user.email
        ).generate_pdf

        rendered_pdf = pdf.render
        page_analysis = PDF::Inspector::Page.analyze(rendered_pdf)
        text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)

        expect(page_analysis.pages.size).to eq(2)
        event_procedures.each do |event_procedure|
          expect(text_analysis.strings).to include(event_procedure.procedure.name)
        end
      end
    end

    context "when entity_name is medical_shifts" do
      it "generates medical_shifts pdf" do
        user = create(:user)
        medical_shifts = create_list(:medical_shift, 9, user: user)
        amount = MedicalShifts::TotalAmountCents.call(user_id: medical_shifts.first.user_id, month: nil)
        pdf = described_class.new(
          relation: medical_shifts, amount: amount, entity_name: "medical_shifts", email: user.email
        ).generate_pdf

        rendered_pdf = pdf.render
        page_analysis = PDF::Inspector::Page.analyze(rendered_pdf)
        text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)

        expect(page_analysis.pages.size).to eq(1)
        medical_shifts.each do |medical_shift|
          expect(text_analysis.strings).to include(medical_shift.hospital_name)
        end
      end
    end
  end
end
