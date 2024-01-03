# frozen_string_literal: true

class HospitalSerializer < ActiveModel::Serializer
  attributes :id, :name, :address
end
