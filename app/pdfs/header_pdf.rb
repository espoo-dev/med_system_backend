# frozen_string_literal: true

class HeaderPdf
  attr_reader :pdf, :title

  def initialize(pdf:, title:)
    @pdf = pdf
    @title = title
    @header_spacing = 20
    @header_font_size = 12
    @title_font_size = 20
  end

  def generate
    pdf.text "Data: #{Time.zone.now.strftime('%d/%m/%Y')}", align: :right, size: @header_font_size
    pdf.move_down @header_spacing
    pdf.text title, align: :center, size: @title_font_size, style: :bold
    pdf.move_down @header_spacing
  end
end
