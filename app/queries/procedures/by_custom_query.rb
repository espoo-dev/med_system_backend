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
      custom == "true" ? relation.where(custom: true, user: user) : relation.where(custom: false)
    end
  end
end
