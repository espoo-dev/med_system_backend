# frozen_string_literal: true

$stdout.puts "8. Creating custom Procedure..."

user = User.last
procedure = Procedure.create!(
  name: "Procedure A CUSTOM",
  code: "123",
  amount_cents: 12_345,
  description: "Desc A",
  custom: true,
  user_id: user.id
)
$stdout.puts "Created custom Procedure: #{procedure.name} (#{procedure.code})"
