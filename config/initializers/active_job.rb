# frozen_string_literal: true

# Sidekiq is not currently processing jobs in production, so deliver
# ActionMailer/Devise e-mails through Active Job's in-process `:async` adapter
# instead of the global `:sidekiq` adapter. This keeps `deliver_later` working
# (non-blocking sign_up, in-memory retries) without Redis/Sidekiq.
#
# Trade-off: jobs live in memory and are lost on process restart/crash.
#
# Tests keep the global adapter so mailer specs stay deterministic.
ActionMailer::MailDeliveryJob.queue_adapter = :async unless Rails.env.test?
