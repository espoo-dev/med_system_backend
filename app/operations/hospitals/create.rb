# frozen_string_literal: true

module Hospitals
  class Create < Actor
    input :attributes, type: Hash

    output :hospital, type: Hospital

    def call
      self.hospital = Hospital.new(attributes)

      fail!(error: :invalid_record) unless hospital.save
    end
  end
end
