# frozen_string_literal: true

class ChangeNameAndAddressToCitextInHospitals < ActiveRecord::Migration[7.0]
  def change
    change_table :hospitals, bulk: true do |t|
      t.change :name, :citext # rubocop:disable Rails/ReversibleMigration
      t.change :address, :citext # rubocop:disable Rails/ReversibleMigration
    end
  end
end
