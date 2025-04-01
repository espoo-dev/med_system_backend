# frozen_string_literal: true

$stdout.puts "1. Creating User..."

user = User.create!(
  email: "user@email.com",
  password: "qwe123",
  password_confirmation: "qwe123"
)
$stdout.puts "Created User with email: #{user.email}"
$stdout.puts "User's password: #{user.password}"
