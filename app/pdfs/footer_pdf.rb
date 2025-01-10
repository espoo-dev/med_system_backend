# frozen_string_literal: true

class FooterPdf
  attr_reader :pdf, :amount

  def initialize(pdf:, amount:)
    @pdf = pdf
    @amount = amount
  end

  def generate
    pdf.bounding_box([0, 30], width: @pdf.bounds.width, height: 50) do
      pdf.stroke_color "000000"
      pdf.stroke_horizontal_line(0, pdf.bounds.width, at: 65)

      pdf.text_box "Total", at: [0, pdf.cursor], size: 10, align: :left
      pdf.text_box amount.total, at: [pdf.bounds.width - 50, pdf.cursor], size: 10, align: :right

      pdf.move_down 15

      pdf.text_box "A Receber", at: [0, pdf.cursor], size: 10, align: :left
      pdf.text_box amount.unpaid, at: [pdf.bounds.width - 50, pdf.cursor], size: 10, align: :right

      pdf.move_down 15

      pdf.text_box "Recebidos", at: [0, pdf.cursor], size: 10, align: :left
      pdf.text_box amount.payd, at: [pdf.bounds.width - 50, pdf.cursor], size: 10, align: :right
    end
  end
end
