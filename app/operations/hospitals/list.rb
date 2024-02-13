# frozen_string_literal: true

module Hospitals
  class List < Actor
    input :scope, type: Enumerable, default: -> { Hospital.all }
    input :params, type: Hash, default: -> { {} }

    output :hospitals, type: Enumerable

    def call
      self.hospitals = scope.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    end
  end
end
