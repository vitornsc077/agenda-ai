FactoryBot.define do
  factory :account do
    sequence(:name) { |n| "Empresa #{n}" }
    sequence(:slug) { |n| "empresa-#{n}" }
    timezone { "America/Sao_Paulo" }
    plan { :trial }
    trial_ends_at { 14.days.from_now }
    active { true }
  end

  factory :user do
    account
    sequence(:name) { |n| "Usuário #{n}" }
    sequence(:email) { |n| "usuario#{n}@exemplo.com" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :owner }
  end

  factory :service do
    account
    sequence(:name) { |n| "Serviço #{n}" }
    duration_minutes { 30 }
    price_cents { 5000 }
    currency { "BRL" }
    active { true }
  end

  factory :staff_member do
    account
    sequence(:name) { |n| "Profissional #{n}" }
    sequence(:email) { |n| "prof#{n}@exemplo.com" }
    active { true }
  end

  factory :work_schedule do
    staff_member
    day_of_week { 1 } # Monday
    start_time { "09:00" }
    end_time { "18:00" }
    enabled { true }
  end

  factory :client do
    account
    sequence(:name) { |n| "Cliente #{n}" }
    sequence(:email) { |n| "cliente#{n}@exemplo.com" }
    phone { "(11) 99999-8888" }
  end

  factory :schedule_override do
    staff_member
    override_date { Date.current }
    override_type { :block }
  end

  factory :booking do
    account
    service { association :service, account: account }
    staff_member { association :staff_member, account: account }
    client { association :client, account: account }
    starts_at { 1.day.from_now.change(hour: 10, min: 0) }
    ends_at { starts_at + 30.minutes }
    status { :confirmed }
    price_cents { 5000 }
    currency { "BRL" }
  end
end
