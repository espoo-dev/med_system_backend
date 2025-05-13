# frozen_string_literal: true

module Users
  class DestroySelf
    Result = Struct.new(:success?, :error)

    def initialize(user, password)
      @user = user
      @password = password
    end

    def call
      return Result.new(false, "Wrong password") unless valid_password?

      ActiveRecord::Base.transaction do
        destroy_event_procedures!
        destroy_medical_shifts!
        destroy_patients!
        destroy_procedures!
        destroy_health_insurances!

        @user.destroy
      end

      Result.new(true, nil)
    rescue StandardError => e
      Result.new(false, e.message)
    end

    private

    def valid_password?
      @user.valid_password?(@password)
    end

    def destroy_event_procedures!
      @user.event_procedures.destroy_all
    end

    def destroy_medical_shifts!
      @user.medical_shifts.destroy_all
    end

    def destroy_health_insurances!
      @user.health_insurances.destroy_all
    end

    def destroy_procedures!
      @user.procedures.destroy_all
    end

    def destroy_patients!
      @user.patients.each do |patient|
        if patient.event_procedures.exists?(deleted_at: nil)
          raise ActiveRecord::InvalidForeignKey, "Patient ##{patient.id} has associated procedures"
        end

        patient.destroy
      end
    end
  end
end
