# frozen_string_literal: true

class ChangeCodeToCitextInProcedures < ActiveRecord::Migration[7.0]
  def change
    enable_extension "citext" unless extension_enabled?("citext")
    change_column :procedures, :code, :citext # rubocop:disable Rails/ReversibleMigration
  end
end
