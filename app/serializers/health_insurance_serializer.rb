# frozen_string_literal: true

class HealthInsuranceSerializer < ActiveModel::Serializer
  attributes :id, :name, :custom, :user_id
end
