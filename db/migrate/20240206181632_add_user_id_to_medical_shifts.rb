# frozen_string_literal: true

class AddUserIdToMedicalShifts < ActiveRecord::Migration[7.0]
  def change
    add_reference :medical_shifts, :user, null: false, foreign_key: true, index: true # rubocop:disable Rails/NotNullColumn
  end
end
