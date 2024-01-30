# frozen_string_literal: true

module MedicalShifts
  class List < Actor
    input :page, type: String, allow_nil: true
    input :per_page, type: String, allow_nil: true

    output :medical_shifts, type: Enumerable

    def call
      self.medical_shifts = MedicalShift.order(created_at: :desc).page(page).per(per_page)
    end
  end
end
