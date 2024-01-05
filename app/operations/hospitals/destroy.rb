# frozen_string_literal: true

module Hospitals
  class Destroy < Actor
    input :id, type: String

    output :hospital, type: Hospital

    def call
      self.hospital = Hospital.find(id)

      fail!(error: :cannot_destroy) unless hospital.destroy
    end
  end
end
