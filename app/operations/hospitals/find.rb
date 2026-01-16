# frozen_string_literal: true

module Hospitals
  class Find < Actor
    input :id, type: String
    input :scope, type: Enumerable, default: -> { Hospital.all }

    output :hospital, type: Hospital

    def call
      self.hospital = scope.find(id)
    end
  end
end
