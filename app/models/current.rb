class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :account

  def user
    session&.user
  end
end
