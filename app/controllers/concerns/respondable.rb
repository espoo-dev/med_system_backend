# frozen_string_literal: true

module Respondable
  extend ActiveSupport::Concern

  def deleted_successfully_render(record)
    render json: { message: "#{record.class} deleted successfully." }, status: :ok
  end
end
