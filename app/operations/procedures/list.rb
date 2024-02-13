# frozen_string_literal: true

module Procedures
  class List < Actor
    input :scope, type: Enumerable, default: -> { Procedure.all }
    input :params, type: Hash, default: -> { {} }

    output :procedures, type: Enumerable

    def call
      self.procedures = scope.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    end
  end
end
