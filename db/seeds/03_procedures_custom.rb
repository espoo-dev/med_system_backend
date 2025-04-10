# frozen_string_literal: true

Rails.logger.debug "8. Creating custom Procedure..."

user = User.last
procedure = Procedure.create!(
  name: "Procedure A CUSTOM",
  code: "123",
  amount_cents: 12_345,
  description: "Desc A",
  custom: true,
  user_id: user.id
)
Rails.logger.debug { "Created custom Procedure: #{procedure.name} (#{procedure.code})" }
