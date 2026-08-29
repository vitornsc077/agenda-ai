module Admin
  class BillingController < BaseController
    def index
      @account = current_account
      @trial_service = TrialStatusService.new(@account)
    end

    def create_checkout_session
      interval = params[:interval] == "year" ? "year" : "month"
      unit_amount = interval == "year" ? 54900 : 7990
      plan_name = interval == "year" ? "AgendaAI — Plano Anual" : "AgendaAI — Plano Mensal"

      # Ensure Stripe Customer exists
      customer_id = current_account.stripe_customer_id
      if customer_id.blank?
        customer = Stripe::Customer.create({
          name: current_account.name,
          email: current_user.email,
          metadata: {
            account_id: current_account.id,
            account_slug: current_account.slug
          }
        })
        current_account.update!(stripe_customer_id: customer.id)
        customer_id = customer.id
      end

      # Create Stripe Checkout Session
      session = Stripe::Checkout::Session.create({
        customer: customer_id,
        mode: "subscription",
        payment_method_types: ["card"],
        line_items: [{
          price_data: {
            currency: "brl",
            product_data: {
              name: plan_name,
              description: "Assinatura da plataforma completa de agendamento online AgendaAI"
            },
            unit_amount: unit_amount,
            recurring: {
              interval: interval
            }
          },
          quantity: 1
        }],
        metadata: {
          account_id: current_account.id,
          interval: interval
        },
        subscription_data: {
          metadata: {
            account_id: current_account.id,
            interval: interval
          }
        },
        success_url: admin_billing_success_url + "?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: admin_billing_cancel_url
      })

      redirect_to session.url, allow_other_host: true, status: :see_other
    rescue Stripe::StripeError => e
      redirect_to admin_billing_path, alert: "Erro ao comunicar com o Stripe: #{e.message}"
    end

    def customer_portal
      if current_account.stripe_customer_id.blank?
        redirect_to admin_billing_path, alert: "Nenhuma assinatura ativa encontrada para este tenant."
        return
      end

      portal_session = Stripe::BillingPortal::Session.create({
        customer: current_account.stripe_customer_id,
        return_url: admin_billing_url
      })

      redirect_to portal_session.url, allow_other_host: true, status: :see_other
    rescue Stripe::StripeError => e
      redirect_to admin_billing_path, alert: "Erro ao abrir o portal do cliente: #{e.message}"
    end

    def success
      if params[:session_id].present?
        begin
          checkout_session = Stripe::Checkout::Session.retrieve(params[:session_id])
          if checkout_session.payment_status == "paid" || checkout_session.status == "complete"
            current_account.update!(
              stripe_customer_id: checkout_session.customer,
              stripe_subscription_id: checkout_session.subscription,
              subscription_status: "active",
              subscription_interval: checkout_session.metadata["interval"].presence || "month",
              plan: :professional
            )
          end
        rescue Stripe::StripeError => e
          Rails.logger.error("Failed to sync checkout session: #{e.message}")
        end
      end
    end

    def cancel
    end
  end
end
