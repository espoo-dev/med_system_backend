# frozen_string_literal: true

class PdfGeneratorService
  attr_reader :relation, :amount, :entity_name

  def initialize(relation:, amount:, entity_name:)
    @relation = relation
    @amount = amount
    @entity_name = entity_name
  end

  def generate_pdf
    entity_name == "event_procedures" ? generate_event_procedures_pdf : generate_medical_shifts_pdf
  end

  private

  def generate_event_procedures_pdf
    Prawn::Document.new do |pdf|
      EventProceduresReportPdf.new(pdf: pdf, items: relation, amount: amount, title: "Procedimentos").generate
    end
  end

  def generate_medical_shifts_pdf
    Prawn::Document.new do |pdf|
      MedicalShiftsReportPdf.new(pdf: pdf, items: relation, amount: amount, title: "Plantões").generate
    end
  end
end
