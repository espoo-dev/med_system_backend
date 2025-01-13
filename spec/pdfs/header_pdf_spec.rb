# frozen_string_literal: true

require "rails_helper"

RSpec.describe HeaderPdf, type: :pdf do
  it "generates a header with the correct content" do
    pdf = Prawn::Document.new
    date = "Data: #{Time.zone.now.strftime('%d/%m/%Y')}"
    title = "Procedimentos"

    described_class.new(pdf: pdf, title: title).generate
    rendered_pdf = pdf.render
    text_analysis = PDF::Inspector::Text.analyze(rendered_pdf)

    expect(text_analysis.strings).to include(date, title)
  end
end
