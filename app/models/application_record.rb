class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_create :set_uuid_primary_key, if: -> { self.class.primary_key == "id" && id.blank? }

  private

  def set_uuid_primary_key
    self.id = SecureRandom.uuid_v7
  end
end
