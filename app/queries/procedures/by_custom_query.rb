# frozen_string_literal: true

module Procedures
  class ByCustomQuery < ApplicationQuery
    attr_reader :custom, :user, :relation

    def initialize(custom:, user:, relation: Procedure)
      @custom = custom
      @user = user
      @relation = relation
    end

    def call
      if custom == "true"
        relation
          .select("DISTINCT ON (procedures.name) procedures.*")
          .where(custom: true, user: user)
          .order("procedures.name, procedures.created_at DESC")
      else
        relation.where(custom: false)
      end
    end
  end
end
