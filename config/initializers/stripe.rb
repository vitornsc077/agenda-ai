require "stripe"

Rails.configuration.stripe = {
  publishable_key: ENV.fetch("STRIPE_PUBLISHABLE_KEY", "pk_test_51U9nPLLnzQiVTVEumen6XGhhTtgPPzPFIRQZgjO3O2Pr6TaT368jzvNxGfVwXYZk2OXOE5HTdumAThFnnNoUrDp700Y9PrY3lt"),
  secret_key: ENV.fetch("STRIPE_SECRET_KEY", "sk_test_placeholder"),
  webhook_secret: ENV.fetch("STRIPE_WEBHOOK_SECRET", nil)
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
