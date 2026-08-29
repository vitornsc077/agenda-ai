module Webhooks
  class StripeController < ApplicationController
    allow_unauthenticated_access
    skip_before_action :verify_authenticity_token

    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      webhook_secret = Rails.configuration.stripe[:webhook_secret]

      event = if webhook_secret.present?
                begin
                  Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
                rescue JSON::ParserError, Stripe::SignatureVerificationError => e
                  return render json: { error: e.message }, status: :bad_request
                end
              else
                begin
                  data = JSON.parse(payload)
                  Stripe::Event.construct_from(data)
                rescue JSON::ParserError => e
                  return render json: { error: e.message }, status: :bad_request
                end
              end

      case event.type
      when "checkout.session.completed"
        handle_checkout_session_completed(event.data.object)
      when "customer.subscription.created", "customer.subscription.updated"
        handle_subscription_updated(event.data.object)
      when "customer.subscription.deleted"
        handle_subscription_deleted(event.data.object)
      when "invoice.payment_succeeded"
        handle_invoice_payment_succeeded(event.data.object)
      when "invoice.payment_failed"
        handle_invoice_payment_failed(event.data.object)
      end

      render json: { status: "success" }
    end

    private

    def handle_checkout_session_completed(session)
      metadata = session["metadata"] || {}
      account_id = metadata["account_id"]
      account = Account.find_by(id: account_id) || Account.find_by(stripe_customer_id: session["customer"])
      return unless account

      interval = metadata["interval"].presence || "month"

      account.update!(
        stripe_customer_id: session["customer"],
        stripe_subscription_id: session["subscription"],
        subscription_status: "active",
        subscription_interval: interval,
        plan: :professional
      )
    end

    def handle_subscription_updated(subscription)
      account = Account.find_by(stripe_subscription_id: subscription["id"]) ||
                Account.find_by(stripe_customer_id: subscription["customer"])
      return unless account

      items_data = subscription.dig("items", "data") || []
      first_item = items_data.first || {}
      price = first_item["price"] || {}
      recurring = price["recurring"] || {}
      
      interval = recurring["interval"] ||
                 subscription.dig("metadata", "interval") ||
                 account.subscription_interval ||
                 "month"

      period_end = Time.at(subscription["current_period_end"]) rescue nil

      account.update!(
        stripe_subscription_id: subscription["id"],
        subscription_status: subscription["status"],
        subscription_interval: interval,
        current_period_end: period_end,
        plan: subscription["status"] == "active" ? :professional : account.plan
      )
    end

    def handle_subscription_deleted(subscription)
      account = Account.find_by(stripe_subscription_id: subscription["id"])
      return unless account

      account.update!(
        subscription_status: "canceled",
        plan: :trial
      )
    end

    def handle_invoice_payment_succeeded(invoice)
      return unless invoice["subscription"]
      account = Account.find_by(stripe_subscription_id: invoice["subscription"]) ||
                Account.find_by(stripe_customer_id: invoice["customer"])
      return unless account

      account.update!(
        subscription_status: "active",
        plan: :professional
      )
    end

    def handle_invoice_payment_failed(invoice)
      return unless invoice["subscription"]
      account = Account.find_by(stripe_subscription_id: invoice["subscription"])
      return unless account

      account.update!(subscription_status: "past_due")
    end
  end
end
