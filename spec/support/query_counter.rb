# frozen_string_literal: true

module QueryCounter
  def count_queries(&)
    count = 0
    counter_f = lambda { |_name, _started, _finished, _unique_id, payload|
      count += 1 unless payload[:name].in? %w[CACHE SCHEMA]
    }
    ActiveSupport::Notifications.subscribed(counter_f, "sql.active_record", &)
    count
  end
end

RSpec.configure do |config|
  config.include QueryCounter, type: :request
end
