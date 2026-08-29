class AddStripeFieldsToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :stripe_customer_id, :string
    add_column :accounts, :stripe_subscription_id, :string
    add_column :accounts, :subscription_status, :string, default: "trialing"
    add_column :accounts, :subscription_interval, :string
    add_column :accounts, :current_period_end, :datetime

    add_index :accounts, :stripe_customer_id
    add_index :accounts, :stripe_subscription_id
  end
end
