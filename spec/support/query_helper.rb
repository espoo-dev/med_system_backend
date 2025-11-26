# frozen_string_literal: true

module QueryHelper
  def count_queries(&)
    queries = []
    callback = lambda do |_name, _start, _finish, _id, payload|
      queries << payload[:sql] unless /SCHEMA|TRANSACTION/.match?(payload[:name])
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &)
    queries.count
  end
end
