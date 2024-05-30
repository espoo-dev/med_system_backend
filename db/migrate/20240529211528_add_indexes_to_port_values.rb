# frozen_string_literal: true

class AddIndexesToPortValues < ActiveRecord::Migration[7.0]
  def change
    add_index :port_values, %i[cbhpm_id anesthetic_port]
  end
end
