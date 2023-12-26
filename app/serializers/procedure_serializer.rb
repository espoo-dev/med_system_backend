# frozen_string_literal: true

class ProcedureSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :description, :amount_cents

  def amount_cents
    object.amount.format
  end
end
