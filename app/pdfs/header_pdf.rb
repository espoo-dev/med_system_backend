# frozen_string_literal: true

class HeaderPdf
  attr_reader :pdf, :title, :email

  HEADER_FONT_SIZE = 12
  TITLE_FONT_SIZE = 20
  EMAIL_FONT_SIZE = 10
  PROJECT_FONT_SIZE = 12

  def initialize(pdf:, title:, email:)
    @pdf = pdf
    @title = title
    @email = email
  end

  def generate
    pdf.bounding_box([0, pdf.cursor], width: pdf.bounds.width) do
      pdf_logo
      pdf.text_box "Distrito Médico", at: [60, pdf.cursor - 10], size: PROJECT_FONT_SIZE, style: :bold
      pdf.text_box email, at: [60, pdf.cursor - 25], size: EMAIL_FONT_SIZE
      pdf.text_box title, at: [60, pdf.cursor - 45], size: TITLE_FONT_SIZE, align: :center
      header_current_date
    end
    header_spacing
  end

  private

  def logo_path
    Rails.root.join("app/assets/images/logo.png")
  end

  def pdf_logo
    pdf.image logo_path, width: 50, at: [0, pdf.cursor]
  end

  def header_spacing
    pdf.move_down 50
  end

  def header_current_date
    pdf.text_box Time.zone.now.strftime("%d/%m/%Y"), at: [60, pdf.cursor - 40], size: @header_font_size
  end
end
