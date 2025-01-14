# frozen_string_literal: true

class FooterPdf
  attr_reader :pdf, :amount

  def initialize(pdf:, amount:)
    @pdf = pdf
    @amount = amount
    @footer_height = 50
    @footer_spacing = 15
    @footer_font_size = 10
    @right_text_offset = 50
  end

  def generate
    pdf.bounding_box([0, 30], width: @pdf.bounds.width, height: @footer_height) do
      pdf.stroke_color "000000"
      pdf.stroke_horizontal_line(0, pdf.bounds.width, at: 65)

      pdf.text_box "Total", at: [0, pdf.cursor], size: @footer_font_size, align: :left, overflow: :shrink_to_fit
      pdf.text_box amount.total, at: [pdf.bounds.width - @right_text_offset, pdf.cursor], size: @footer_font_size,
        align: :right, overflow: :shrink_to_fit

      pdf.move_down @footer_spacing

      pdf.text_box "A Receber", at: [0, pdf.cursor], size: @footer_font_size, align: :left
      pdf.text_box amount.unpaid, at: [pdf.bounds.width - @right_text_offset, pdf.cursor], size: @footer_font_size,
        align: :right, overflow: :shrink_to_fit

      pdf.move_down @footer_spacing

      pdf.text_box "Recebidos", at: [0, pdf.cursor], size: @footer_font_size, align: :left, overflow: :shrink_to_fit
      pdf.text_box amount.payd, at: [pdf.bounds.width - @right_text_offset, pdf.cursor], size: @footer_font_size,
        align: :right, overflow: :shrink_to_fit
    end
  end
end
