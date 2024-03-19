# frozen_string_literal: true

class ProcedureSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :description, :amount_cents, :custom, :user_id

  def amount_cents
    object.amount.format
  end
end
