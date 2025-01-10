# frozen_string_literal: true

class HeaderPdf
  attr_reader :pdf, :title

  def initialize(pdf:, title:)
    @pdf = pdf
    @title = title
  end

  def generate
    pdf.text "Data: #{Time.zone.now.strftime('%d/%m/%Y')}", align: :right, size: 12
    pdf.move_down 20
    pdf.text title, align: :center, size: 20, style: :bold
    pdf.move_down 20
  end
end
