class CreateAgendaAiSchema < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts, id: :string do |t|
      t.string   :name,         null: false
      t.string   :slug,         null: false
      t.string   :subdomain
      t.string   :logo_url
      t.json     :brand_colors, default: {}
      t.string   :timezone,     null: false, default: "America/Sao_Paulo"
      t.integer  :plan,         null: false, default: 0
      t.datetime :trial_ends_at
      t.boolean  :active,       null: false, default: true

      t.timestamps
    end

    add_index :accounts, :slug, unique: true
    add_index :accounts, :subdomain, unique: true

    create_table :users, id: :string do |t|
      t.string   :account_id,      null: false
      t.string   :email,           null: false
      t.string   :password_digest, null: false
      t.string   :name,            null: false
      t.integer  :role,            null: false, default: 0

      t.timestamps
    end

    add_index :users, [:account_id, :email], unique: true
    add_foreign_key :users, :accounts

    create_table :sessions, id: :string do |t|
      t.string   :user_id,    null: false
      t.string   :ip_address
      t.string   :user_agent

      t.timestamps
    end

    add_foreign_key :sessions, :users

    create_table :services, id: :string do |t|
      t.string   :account_id,       null: false
      t.string   :name,             null: false
      t.text     :description
      t.integer  :duration_minutes, null: false, default: 60
      t.integer  :price_cents
      t.string   :currency,         default: "BRL"
      t.boolean  :active,           null: false, default: true
      t.integer  :position,         null: false, default: 0

      t.timestamps
    end

    add_index :services, [:account_id, :active]
    add_foreign_key :services, :accounts

    create_table :staff_members, id: :string do |t|
      t.string   :account_id, null: false
      t.string   :user_id
      t.string   :name,       null: false
      t.string   :email,      null: false
      t.string   :phone
      t.text     :bio
      t.string   :avatar_url
      t.boolean  :active,     null: false, default: true

      t.timestamps
    end

    add_index :staff_members, [:account_id, :email], unique: true
    add_foreign_key :staff_members, :accounts
    add_foreign_key :staff_members, :users

    create_table :service_staff_members, id: :string do |t|
      t.string :service_id,      null: false
      t.string :staff_member_id, null: false

      t.timestamps
    end

    add_index :service_staff_members, [:service_id, :staff_member_id], unique: true
    add_foreign_key :service_staff_members, :services
    add_foreign_key :service_staff_members, :staff_members

    create_table :work_schedules, id: :string do |t|
      t.string  :staff_member_id, null: false
      t.integer :day_of_week,     null: false
      t.string  :start_time,      null: false, default: "09:00"
      t.string  :end_time,        null: false, default: "18:00"
      t.boolean :enabled,         null: false, default: true

      t.timestamps
    end

    add_index :work_schedules, [:staff_member_id, :day_of_week]
    add_foreign_key :work_schedules, :staff_members

    create_table :schedule_overrides, id: :string do |t|
      t.string  :staff_member_id, null: false
      t.date    :override_date,   null: false
      t.string  :start_time
      t.string  :end_time
      t.integer :override_type,   null: false, default: 0
      t.string  :reason

      t.timestamps
    end

    add_index :schedule_overrides, [:staff_member_id, :override_date]
    add_foreign_key :schedule_overrides, :staff_members

    create_table :clients, id: :string do |t|
      t.string  :account_id,     null: false
      t.string  :name,           null: false
      t.string  :email,          null: false
      t.string  :phone
      t.text    :notes
      t.integer :bookings_count, null: false, default: 0

      t.timestamps
    end

    add_index :clients, [:account_id, :email], unique: true
    add_foreign_key :clients, :accounts

    create_table :bookings, id: :string do |t|
      t.string   :account_id,          null: false
      t.string   :service_id,          null: false
      t.string   :staff_member_id,     null: false
      t.string   :client_id,           null: false
      t.datetime :starts_at,           null: false
      t.datetime :ends_at,             null: false
      t.integer  :status,              null: false, default: 0
      t.integer  :price_cents
      t.string   :currency,            default: "BRL"
      t.text     :notes
      t.text     :cancellation_reason
      t.string   :token,               null: false

      t.timestamps
    end

    add_index :bookings, :token, unique: true
    add_index :bookings, [:staff_member_id, :starts_at, :ends_at]
    add_index :bookings, [:account_id, :starts_at]
    add_index :bookings, :client_id
    add_foreign_key :bookings, :accounts
    add_foreign_key :bookings, :services
    add_foreign_key :bookings, :staff_members
    add_foreign_key :bookings, :clients

    create_table :notifications, id: :string do |t|
      t.string   :booking_id,        null: false
      t.integer  :notification_type, null: false
      t.integer  :channel,           null: false, default: 0
      t.integer  :status,            null: false, default: 0
      t.datetime :sent_at
      t.datetime :scheduled_for

      t.timestamps
    end

    add_index :notifications, [:booking_id, :notification_type, :channel], unique: true, name: "index_notifications_on_booking_type_channel"
    add_index :notifications, [:status, :scheduled_for]
    add_foreign_key :notifications, :bookings
  end
end
