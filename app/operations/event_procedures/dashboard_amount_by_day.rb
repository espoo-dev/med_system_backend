# frozen_string_literal: true

module EventProcedures
  class DashboardAmountByDay < Actor
    input :start_date, type: String
    input :end_date, type: String
    input :user_id, allow_nil: true, default: -> {}

    output :dashboard_data, type: Hash
    attr_reader :start_date_time, :end_date_time

    def call
      set_date_times
      event_procedures = EventProcedure.date_between(start_date: start_date_time, end_date: end_date_time)
      event_procedures = event_procedures.where(user_id:) if user_id.present?

      self.dashboard_data = {
        start_date:,
        end_date:,
        days: event_procedures_by_date(event_procedures),
        events_amount: event_procedures.count
      }
    end

    private

    def set_date_times
      @start_date_time = format_to_datetime(start_date)
      @end_date_time = format_to_datetime(end_date)
    rescue Date::Error
      fail!(error: "invalid data format, it must be dd/mm/yyyy")
    end

    def event_procedures_by_date(event_procedures)
      result = {}
      date_range = start_date_time..end_date_time

      date_range.each do |date_time|
        formatted_date_time = format_from_datetime(date_time)
        result[formatted_date_time] = 0
      end

      event_procedures.each do |event_procedure|
        formatted_date_time = format_from_datetime(event_procedure.date)
        result[formatted_date_time] += 1
      end

      result
    end

    def format_from_datetime(date)
      date.strftime("%d/%m/%Y")
    end

    def format_to_datetime(date)
      DateTime.strptime(date, "%d/%m/%Y")
    end
  end
end
