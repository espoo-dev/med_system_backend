# frozen_string_literal: true

module Hospitals
  class Update < Actor
    input :id, type: String
    input :attributes, type: Hash

    output :hospital, type: Hospital

    def call
      self.hospital = find_hospital

      fail!(error: :invalid_record) unless hospital.update(attributes)
    end

    private

    def find_hospital
      Hospitals::Find.result(id: id).hospital
    end
  end
end
