# frozen_string_literal: true

module Hospitals
  class Find < Actor
    input :id, type: String

    output :hospital, type: Hospital

    def call
      self.hospital = Hospital.find(id)
    end
  end
end
