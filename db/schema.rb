# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_29_190132) do
  create_table "accounts", id: :string, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.json "brand_colors", default: {}
    t.datetime "created_at", null: false
    t.datetime "current_period_end"
    t.string "logo_url"
    t.string "name", null: false
    t.integer "plan", default: 0, null: false
    t.string "slug", null: false
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.string "subdomain"
    t.string "subscription_interval"
    t.string "subscription_status", default: "trialing"
    t.string "timezone", default: "America/Sao_Paulo", null: false
    t.datetime "trial_ends_at"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_accounts_on_slug", unique: true
    t.index ["stripe_customer_id"], name: "index_accounts_on_stripe_customer_id"
    t.index ["stripe_subscription_id"], name: "index_accounts_on_stripe_subscription_id"
    t.index ["subdomain"], name: "index_accounts_on_subdomain", unique: true
  end

  create_table "bookings", id: :string, force: :cascade do |t|
    t.string "account_id", null: false
    t.text "cancellation_reason"
    t.string "client_id", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "BRL"
    t.datetime "ends_at", null: false
    t.text "notes"
    t.integer "price_cents"
    t.string "service_id", null: false
    t.string "staff_member_id", null: false
    t.datetime "starts_at", null: false
    t.integer "status", default: 0, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "starts_at"], name: "index_bookings_on_account_id_and_starts_at"
    t.index ["client_id"], name: "index_bookings_on_client_id"
    t.index ["staff_member_id", "starts_at", "ends_at"], name: "index_bookings_on_staff_member_id_and_starts_at_and_ends_at"
    t.index ["token"], name: "index_bookings_on_token", unique: true
  end

  create_table "clients", id: :string, force: :cascade do |t|
    t.string "account_id", null: false
    t.integer "bookings_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["account_id", "email"], name: "index_clients_on_account_id_and_email", unique: true
  end

  create_table "notifications", id: :string, force: :cascade do |t|
    t.string "booking_id", null: false
    t.integer "channel", default: 0, null: false
    t.datetime "created_at", null: false
    t.integer "notification_type", null: false
    t.datetime "scheduled_for"
    t.datetime "sent_at"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id", "notification_type", "channel"], name: "index_notifications_on_booking_type_channel", unique: true
    t.index ["status", "scheduled_for"], name: "index_notifications_on_status_and_scheduled_for"
  end

  create_table "schedule_overrides", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "end_time"
    t.date "override_date", null: false
    t.integer "override_type", default: 0, null: false
    t.string "reason"
    t.string "staff_member_id", null: false
    t.string "start_time"
    t.datetime "updated_at", null: false
    t.index ["staff_member_id", "override_date"], name: "index_schedule_overrides_on_staff_member_id_and_override_date"
  end

  create_table "service_staff_members", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "service_id", null: false
    t.string "staff_member_id", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id", "staff_member_id"], name: "index_service_staff_members_on_service_id_and_staff_member_id", unique: true
  end

  create_table "services", id: :string, force: :cascade do |t|
    t.string "account_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "BRL"
    t.text "description"
    t.integer "duration_minutes", default: 60, null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.integer "price_cents"
    t.datetime "updated_at", null: false
    t.index ["account_id", "active"], name: "index_services_on_account_id_and_active"
  end

  create_table "sessions", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.string "user_id", null: false
  end

  create_table "staff_members", id: :string, force: :cascade do |t|
    t.string "account_id", null: false
    t.boolean "active", default: true, null: false
    t.string "avatar_url"
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "phone"
    t.datetime "updated_at", null: false
    t.string "user_id"
    t.index ["account_id", "email"], name: "index_staff_members_on_account_id_and_email", unique: true
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.string "account_id", null: false
    t.string "api_token"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "email"], name: "index_users_on_account_id_and_email", unique: true
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
  end

  create_table "work_schedules", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.boolean "enabled", default: true, null: false
    t.string "end_time", default: "18:00", null: false
    t.string "staff_member_id", null: false
    t.string "start_time", default: "09:00", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_member_id", "day_of_week"], name: "index_work_schedules_on_staff_member_id_and_day_of_week"
  end

  add_foreign_key "bookings", "accounts"
  add_foreign_key "bookings", "clients"
  add_foreign_key "bookings", "services"
  add_foreign_key "bookings", "staff_members"
  add_foreign_key "clients", "accounts"
  add_foreign_key "notifications", "bookings"
  add_foreign_key "schedule_overrides", "staff_members"
  add_foreign_key "service_staff_members", "services"
  add_foreign_key "service_staff_members", "staff_members"
  add_foreign_key "services", "accounts"
  add_foreign_key "sessions", "users"
  add_foreign_key "staff_members", "accounts"
  add_foreign_key "staff_members", "users"
  add_foreign_key "users", "accounts"
  add_foreign_key "work_schedules", "staff_members"
end
