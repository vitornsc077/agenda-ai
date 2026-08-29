require 'rails_helper'

RSpec.describe Account, type: :model do
  describe "validations" do
    subject { build(:account) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:timezone) }
    it { should validate_uniqueness_of(:slug) }
  end

  describe "slug generation" do
    it "generates parameterize slug from name automatically" do
      account = Account.create!(name: "Salão Beleza Pura")
      expect(account.slug).to eq("salao-beleza-pura")
    end

    it "handles duplicate names with sequential suffix" do
      acc1 = Account.create!(name: "Clínica Vida")
      acc2 = Account.create!(name: "Clínica Vida")
      expect(acc1.slug).to eq("clinica-vida")
      expect(acc2.slug).to eq("clinica-vida-1")
    end
  end

  describe "trial logic" do
    it "sets 14 days trial by default on creation" do
      account = create(:account, plan: :trial, trial_ends_at: nil)
      expect(account.trial_ends_at).to be_present
      expect(account.trial_days_left).to be_between(13, 15)
      expect(account.trial_expired?).to be false
    end

    it "detects expired trial" do
      account = create(:account, plan: :trial, trial_ends_at: 1.day.ago)
      expect(account.trial_expired?).to be true
      expect(account.trial_days_left).to eq(0)
    end
  end
end
