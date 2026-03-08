# frozen_string_literal: true

require "rails_helper"

RSpec.describe PdfGeneratorService, type: :service do
  describe "#generate_pdf" do
    context "when entity_name is event_procedures" do
      it "generates event_procedures pdf" do
        user = create(:user)
        event_procedures = create_list(:event_procedure, 11)
        amount = EventProcedures::TotalAmountCents.call(event_procedures: event_procedures)
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

      context "when hide_values is true" do
        it "generates pdf without monetary values" do
          user = create(:user)
          event_procedures = create_list(:event_procedure, 3)
          amount = EventProcedures::TotalAmountCents.call(event_procedures: event_procedures)
          pdf = described_class.new(
            relation: event_procedures, amount: amount, entity_name: "event_procedures",
            email: user.email, hide_values: true
          ).generate_pdf

          text_analysis = PDF::Inspector::Text.analyze(pdf.render)

          expect(text_analysis.strings).not_to include(amount.total, amount.paid, amount.unpaid)
        end
      end
    end

    context "when entity_name is medical_shifts" do
      it "generates medical_shifts pdf" do
        user = create(:user)
        medical_shifts = create_list(:medical_shift, 9, user: user)
        amount = MedicalShifts::TotalAmountCents.call(medical_shifts: [medical_shifts[0]])
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

      context "when hide_values is true" do
        it "generates pdf without monetary values" do
          user = create(:user)
          medical_shifts = create_list(:medical_shift, 3, user: user)
          amount = MedicalShifts::TotalAmountCents.call(medical_shifts: medical_shifts)
          pdf = described_class.new(
            relation: medical_shifts, amount: amount, entity_name: "medical_shifts",
            email: user.email, hide_values: true
          ).generate_pdf

          text_analysis = PDF::Inspector::Text.analyze(pdf.render)

          expect(text_analysis.strings).not_to include(amount.total, amount.paid, amount.unpaid)
        end
      end
    end
  end
end
