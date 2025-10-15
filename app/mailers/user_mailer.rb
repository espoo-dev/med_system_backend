# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def test_email
    mail(
      to: "delivered@resend.dev",
      from: "onboarding@resend.dev",
      subject: "Teste de email do Resend",
      body: "Este é um email de teste simples para verificar se o Resend está funcionando!"
    )
  end
end
