# frozen_string_literal: true

class PdfReportPolicy < ApplicationPolicy
  def generate?
    user.present?
  end
end
