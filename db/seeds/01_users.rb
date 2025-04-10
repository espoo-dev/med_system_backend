# frozen_string_literal: true

Rails.logger.debug "1. Creating User..."

user = User.create!(
  email: "user@email.com",
  password: "qwe123",
  password_confirmation: "qwe123"
)
Rails.logger.debug { "Created User with email: #{user.email}" }
Rails.logger.debug { "User's password: #{user.password}" }
