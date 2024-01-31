# frozen_string_literal: true

module MedicalShifts
  class List < Actor
    input :page, type: String, allow_nil: true
    input :per_page, type: String, allow_nil: true
    input :payd, type: String, allow_nil: true
    input :month, type: String, allow_nil: true
    input :hospital_id, type: String, allow_nil: true

    output :medical_shifts, type: Enumerable

    def call
      query = MedicalShift.includes([:hospital])

      query = query.where("EXTRACT(MONTH FROM date) = ?", month) if month.present?
      query = query.where(hospital_id: hospital_id) if hospital_id.present?
      query = filter_by_payd(query)

      self.medical_shifts = query.order(created_at: :desc).page(page).per(per_page)
    end

    private

    def filter_by_payd(query)
      return query unless filtered_by_payd?

      payd == "true" ? query.where(was_paid: true) : query.where(was_paid: false)
    end

    def filtered_by_payd?
      %w[true false].include?(payd)
    end
  end
end
