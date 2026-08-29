class BookingMailer < ApplicationMailer
  default from: "AgendaAI <notifications@agendaai.com>"

  def confirmation_client(booking)
    @booking = booking
    @client = booking.client
    @service = booking.service
    @staff = booking.staff_member
    @account = booking.account

    mail(
      to: @client.email,
      subject: "Agendamento Confirmado — #{@service.name} em #{@account.name}"
    )
  end

  def confirmation_staff(booking)
    @booking = booking
    @client = booking.client
    @service = booking.service
    @staff = booking.staff_member
    @account = booking.account

    mail(
      to: @staff.email,
      subject: "Novo Agendamento: #{@client.name} — #{@service.name}"
    )
  end

  def reminder_24h(booking)
    @booking = booking
    @client = booking.client
    @service = booking.service
    @staff = booking.staff_member
    @account = booking.account

    mail(
      to: @client.email,
      subject: "Lembrete de Agendamento: Amanhã às #{@booking.starts_at.strftime('%H:%M')} — #{@account.name}"
    )
  end

  def cancellation_notice(booking)
    @booking = booking
    @client = booking.client
    @service = booking.service
    @staff = booking.staff_member
    @account = booking.account

    mail(
      to: @client.email,
      subject: "Agendamento Cancelado — #{@service.name} em #{@account.name}"
    )
  end
end
