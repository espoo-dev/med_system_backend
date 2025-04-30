# frozen_string_literal: true

I18n.load_path += Rails.root.glob("/config/locales/**/*.{rb,yml}")
I18n.available_locales = %i[pt-BR en]
I18n.default_locale = :"pt-BR"
