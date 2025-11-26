# frozen_string_literal: true

module MedicalShiftRecurrences
  class RecurrenceDateCalculatorService
    def initialize(recurrence)
      @recurrence = recurrence
    end

    def dates_until(target_date)
      return [] if @recurrence.deleted_at.present?

      dates = []
      current_date = starting_point
      end_date = effective_end_date(target_date)

      while current_date && current_date <= end_date
        dates << current_date
        current_date = next_occurrence(current_date)

        break if dates.size > 365 # Safety
      end

      dates
    end

    private

    def starting_point
      if @recurrence.last_generated_until.present?
        next_occurrence(@recurrence.last_generated_until)
      else
        first_occurrence_after_start_date
      end
    end

    def first_occurrence_after_start_date
      case @recurrence.frequency
      when "weekly"
        find_next_weekly_after(@recurrence.start_date, @recurrence.day_of_week)
      when "biweekly"
        find_next_biweekly_after(@recurrence.start_date, @recurrence.day_of_week)
      when "monthly_fixed_day"
        find_next_month_day_after(@recurrence.start_date, @recurrence.day_of_month)
      end
    end

    def find_next_weekly_after(from_date, target_wday)
      # Se from_date já é o dia correto, pula 7 dias
      return from_date + 7.days if from_date.wday == target_wday

      # Caso contrário, encontra o próximo dia da semana
      days_ahead = target_wday - from_date.wday
      days_ahead += 7 if days_ahead.negative?

      from_date + days_ahead.days
    end

    def find_next_biweekly_after(from_date, target_wday)
      # Se from_date já é o dia correto, pula 14 dias (2 semanas)
      return from_date + 14.days if from_date.wday == target_wday

      # Caso contrário, encontra o próximo dia da semana
      days_ahead = target_wday - from_date.wday
      days_ahead += 7 if days_ahead.negative?

      from_date + days_ahead.days
    end

    def find_next_month_day_after(from_date, target_day)
      # Se é o dia correto no mês atual, pula para o próximo mês
      if from_date.day == target_day && month_has_day?(from_date, target_day)
        return next_month_with_day(from_date, target_day)
      end

      # Tenta no mês atual primeiro
      return from_date.change(day: target_day) if from_date.day < target_day && month_has_day?(from_date, target_day)

      # Se não, próximo mês
      next_month_with_day(from_date, target_day)
    end

    def next_occurrence(from_date)
      case @recurrence.frequency
      when "weekly"
        from_date + 7.days
      when "biweekly"
        from_date + 14.days
      when "monthly_fixed_day"
        next_month_with_day(from_date, @recurrence.day_of_month)
      end
    end

    def next_month_with_day(from_date, target_day)
      current = from_date.next_month.beginning_of_month

      12.times do
        return current.change(day: target_day) if month_has_day?(current, target_day)

        current = current.next_month
      end

      nil
    end

    def month_has_day?(date, day)
      day <= date.end_of_month.day
    end

    def effective_end_date(target_date)
      dates = [target_date]
      dates << @recurrence.end_date if @recurrence.end_date.present?
      dates.min
    end
  end
end
