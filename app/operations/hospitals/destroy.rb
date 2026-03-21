# frozen_string_literal: true

module Hospitals
  class Destroy < Actor
    input :id, type: String
    input :scope, type: Enumerable, default: -> { Hospital.all }

    output :hospital, type: Hospital

    def call
      self.hospital = scope.find(id)

      fail!(error: :cannot_destroy) unless hospital.destroy
    end
  end
end
