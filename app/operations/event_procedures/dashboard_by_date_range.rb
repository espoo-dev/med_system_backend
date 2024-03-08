# frozen_string_literal: true

module EventProcedures
  class DashboardByDateRange < Actor
    input :start_date_time, type: DateTime
    input :end_date_time, type: DateTime

    output :dashboard_data, type: Hash

    def call
      event_procedures = EventProcedure.date_between(start_date: start_date_time, end_date: end_date_time)

      self.dashboard_data = {
        start_date: format_date(start_date_time),
        end_date: format_date(end_date_time),
        days: event_procedures_by_date(event_procedures),
        events_amount: event_procedures.count
      }
    end

    private

    def event_procedures_by_date(event_procedures)
      result = {}
      date_range = start_date_time..end_date_time

      date_range.each do |date_time|
        formatted_date_time = format_date(date_time)
        result[formatted_date_time] = 0
      end

      event_procedures.each do |event_procedure|
        formatted_date_time = format_date(event_procedure.date)
        result[formatted_date_time] += 1
      end

      result
    end

    def format_date(date)
      date.strftime("%d/%m/%Y")
    end
  end
end
