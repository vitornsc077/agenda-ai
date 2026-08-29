class ExpireTrialsJob < ApplicationJob
  queue_as :default

  def perform
    Account.where(plan: :trial)
           .where("trial_ends_at < ?", Time.current)
           .where(active: true)
           .find_each do |account|
      account.update(active: false)
      Rails.logger.info("Account trial expired and deactivated: #{account.name} (id: #{account.id})")
    end
  end
end
