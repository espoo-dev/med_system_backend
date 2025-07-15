# frozen_string_literal: true

module QueryHelper
  def count_queries(&block)
    queries = []
    callback = ->(_name, _start, _finish, _id, payload) do
      queries << payload[:sql] unless payload[:name] =~ /SCHEMA|TRANSACTION/
    end

    ActiveSupport::Notifications.subscribed(callback, "sql.active_record", &block)
    queries.count
  end
end
