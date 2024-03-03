# frozen_string_literal: true

class AddUserRefToPatients < ActiveRecord::Migration[7.0]
  def change
    Patient.destroy_all
    add_reference :patients, :user, foreign_key: true
  end
end
