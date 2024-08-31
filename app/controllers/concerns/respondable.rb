# frozen_string_literal: true

module Respondable
  extend ActiveSupport::Concern

  def deleted_successfully_render(record)
    render json: { message: I18n.t("controllers.actions.delete.success", class_name: record.class) }, status: :ok
  end
end
