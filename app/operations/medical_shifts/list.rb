# frozen_string_literal: true

module MedicalShifts
  class List < Actor
    input :page, type: String, allow_nil: true
    input :per_page, type: String, allow_nil: true
    input :payd, type: String, allow_nil: true
    input :month, type: String, allow_nil: true
    input :hospital_id, type: String, allow_nil: true
    input :user_id, type: Integer

    output :medical_shifts, type: Enumerable

    def call
      self.medical_shifts = filtered_query.order(created_at: :desc).page(page).per(per_page)
    end

    private

    def filtered_query
      query = MedicalShift.includes([:hospital]).where(user_id: user_id)
      query = apply_month_filter(query)
      query = apply_hospital_filter(query)
      apply_payd_filter(query)
    end

    def apply_month_filter(query)
      month.present? ? query.by_month(month: month) : query
    end

    def apply_hospital_filter(query)
      hospital_id.present? ? query.by_hospital(hospital_id: hospital_id) : query
    end

    def apply_payd_filter(query)
      %w[true false].include?(payd) ? query.by_payd(payd: payd) : query
    end
  end
end
