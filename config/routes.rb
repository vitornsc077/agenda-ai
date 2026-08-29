Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route: if authenticated goes to admin dashboard, else to sign in / sign up
  root to: "sessions#new"

  # Authentication
  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]
  resource :password, only: %i[new create]

  # Admin portal
  namespace :admin do
    root to: "dashboard#show"

    resources :services do
      member do
        patch :toggle_active
      end
    end

    resources :staff_members do
      resource :work_schedules, only: %i[update]
      resources :schedule_overrides, only: %i[create destroy]
    end

    resources :bookings do
      member do
        patch :confirm
        patch :cancel
        patch :complete
        patch :no_show
      end
    end

    resource :calendar, controller: :calendar, only: %i[show]

    # Stripe Billing & Subscriptions
    get  "billing",                 to: "billing#index",                  as: :billing
    post "billing/checkout",        to: "billing#create_checkout_session", as: :billing_checkout
    post "billing/portal",          to: "billing#customer_portal",         as: :billing_portal
    get  "billing/success",         to: "billing#success",                as: :billing_success
    get  "billing/cancel",          to: "billing#cancel",                 as: :billing_cancel

    namespace :api do
      get "availability/:staff_member_id/:date", to: "availability#show"
    end
  end

  # Stripe Webhooks
  post "/webhooks/stripe", to: "webhooks/stripe#create"

  # Public booking portal (slug-based)
  get   "/:slug",                     to: "public/booking#show",         as: :public_booking
  get   "/:slug/availability",        to: "public/booking#availability", as: :public_booking_availability
  post  "/:slug/book",                to: "public/booking#create",       as: :public_booking_create
  get   "/:slug/confirmation/:token", to: "public/booking#confirmation", as: :public_booking_confirmation
  patch "/:slug/cancel/:token",       to: "public/booking#cancel",       as: :public_booking_cancel
end
