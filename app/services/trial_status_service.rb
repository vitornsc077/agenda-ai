class TrialStatusService
  def initialize(account)
    @account = account
  end

  def can_accept_bookings?
    @account.has_valid_access?
  end

  def days_remaining
    @account.trial_days_left
  end

  def status_badge
    if @account.active_subscription?
      interval = @account.subscription_interval == "year" ? "Anual" : "Mensal"
      { text: "Assinatura Ativa (#{interval})", class: "bg-emerald-100 text-emerald-800" }
    elsif @account.trial? && !@account.trial_expired?
      { text: "#{days_remaining} dias de teste", class: "bg-amber-100 text-amber-800" }
    else
      { text: "Plano Expirado", class: "bg-rose-100 text-rose-800" }
    end
  end
end
