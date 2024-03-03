# frozen_string_literal: true

module Patients
  class List < Actor
    input :scope, type: Enumerable
    input :params, type: Hash, default: -> { {} }

    output :patients, type: Enumerable

    def call
      self.patients = scope.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    end
  end
end
