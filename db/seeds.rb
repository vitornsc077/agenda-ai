puts "🌱 Criando dados iniciais do AgendaAI..."

# 1. Tenant Account
account = Account.find_or_create_by!(slug: "barbearia-vip") do |acc|
  acc.name = "Barbearia VIP"
  acc.timezone = "America/Sao_Paulo"
  acc.plan = :trial
  acc.trial_ends_at = 14.days.from_now
  acc.active = true
end

ActsAsTenant.with_tenant(account) do
  # 2. Owner User
  user = account.users.find_or_initialize_by(email: "carlos@barbeariavip.com")
  user.name = "Carlos Oliveira"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :owner
  user.save!

  # 3. Staff Members
  carlos = account.staff_members.find_or_create_by!(email: "carlos@barbeariavip.com") do |s|
    s.name = "Carlos Oliveira"
    s.user = user
    s.phone = "(11) 98888-1111"
    s.bio = "Master barber especialista em degradê e visagismo."
    s.active = true
  end

  lucas = account.staff_members.find_or_create_by!(email: "lucas@barbeariavip.com") do |s|
    s.name = "Lucas Mendes"
    s.phone = "(11) 97777-2222"
    s.bio = "Especialista em barboterapia e barba clássica na navalha."
    s.active = true
  end

  # Setup weekly schedules (Seg a Sex: 09:00 - 19:00, Sáb: 09:00 - 17:00)
  [carlos, lucas].each do |staff|
    (1..5).each do |day|
      staff.work_schedules.find_or_create_by!(day_of_week: day) do |ws|
        ws.start_time = "09:00"
        ws.end_time = "19:00"
        ws.enabled = true
      end
    end
    staff.work_schedules.find_or_create_by!(day_of_week: 6) do |ws|
      ws.start_time = "09:00"
      ws.end_time = "17:00"
      ws.enabled = true
    end
    staff.work_schedules.find_or_create_by!(day_of_week: 0) do |ws|
      ws.start_time = "10:00"
      ws.end_time = "15:00"
      ws.enabled = true
    end
  end

  # 4. Services
  s1 = account.services.find_or_create_by!(name: "Corte Cabelo Masculino") do |s|
    s.description = "Corte moderno ou clássico com acabamento na navalha e lavagem inclusa."
    s.duration_minutes = 30
    s.price_cents = 4500
    s.currency = "BRL"
    s.active = true
    s.position = 1
  end

  s2 = account.services.find_or_create_by!(name: "Barboterapia Completa") do |s|
    s.description = "Design de barba com toalha quente, óleos essenciais e hidratação."
    s.duration_minutes = 30
    s.price_cents = 3500
    s.currency = "BRL"
    s.active = true
    s.position = 2
  end

  s3 = account.services.find_or_create_by!(name: "Combo Cabelo + Barba") do |s|
    s.description = "Experiência completa: corte de cabelo + barboterapia com toalha quente."
    s.duration_minutes = 60
    s.price_cents = 7500
    s.currency = "BRL"
    s.active = true
    s.position = 3
  end

  # Link staff to services
  s1.staff_members = [carlos, lucas]
  s2.staff_members = [carlos, lucas]
  s3.staff_members = [carlos]

  # 5. Clients
  client1 = account.clients.find_or_create_by!(email: "joao.silva@exemplo.com") do |c|
    c.name = "João da Silva"
    c.phone = "(11) 91234-5678"
    c.notes = "Prefere corte com máquina 2 dos lados."
  end

  client2 = account.clients.find_or_create_by!(email: "marcos.souza@exemplo.com") do |c|
    c.name = "Marcos Souza"
    c.phone = "(11) 98765-4321"
  end

  # 6. Sample Bookings for today and tomorrow
  today = Date.current
  Time.use_zone("America/Sao_Paulo") do
    # Booking 1
    t1_start = Time.zone.local(today.year, today.month, today.day, 10, 0, 0)
    account.bookings.find_or_create_by!(starts_at: t1_start, staff_member: carlos) do |b|
      b.service = s1
      b.client = client1
      b.ends_at = t1_start + 30.minutes
      b.status = :confirmed
      b.price_cents = s1.price_cents
      b.currency = s1.currency
      b.notes = "Agendado via app"
    end

    # Booking 2
    t2_start = Time.zone.local(today.year, today.month, today.day, 14, 30, 0)
    account.bookings.find_or_create_by!(starts_at: t2_start, staff_member: carlos) do |b|
      b.service = s3
      b.client = client2
      b.ends_at = t2_start + 60.minutes
      b.status = :confirmed
      b.price_cents = s3.price_cents
      b.currency = s3.currency
    end
  end
end

puts "✅ Seeds executados com sucesso!"
puts "➡️ Conta Demo: Barbearia VIP (slug: 'barbearia-vip')"
puts "➡️ Login Admin: carlos@barbeariavip.com / password123"
puts "➡️ Página Pública: http://localhost:3000/barbearia-vip"
