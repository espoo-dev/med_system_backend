# frozen_string_literal: true

class UpdatePatientsNames < ActiveRecord::Migration[7.0]
  def change
    patients = Patient.all

    patients.each do |patient|
      patient.update!(name: patient.name)
    end; nil
  end
end
