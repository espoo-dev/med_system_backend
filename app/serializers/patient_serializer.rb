# frozen_string_literal: true

class PatientSerializer < ActiveModel::Serializer
  attributes :id, :name, :deletable

  def deletable
    object.deletable?
  end
end
