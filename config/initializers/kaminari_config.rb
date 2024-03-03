# frozen_string_literal: true

Kaminari.configure do |config|
  max_int_value = ((2**((0.size * 8) - 2)) - 1)
  config.default_per_page = max_int_value
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
  # config.max_pages = nil
  # config.params_on_first_page = false
end
