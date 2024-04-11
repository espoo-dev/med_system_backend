# frozen_string_literal: true

class RemoveUniquenessConstraintOfAddressOnHospitals < ActiveRecord::Migration[7.0]
  def change
    remove_index :hospitals, :address
  end
end
