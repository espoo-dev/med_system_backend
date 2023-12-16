# frozen_string_literal: true

Money.default_currency = "BRL"
Money.rounding_mode = BigDecimal::ROUND_FLOOR
Money.locale_backend = :i18n
