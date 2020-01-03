class Member < ApplicationRecord
  CAPABILITIES_JSON_SCHEMA = Rails.root.join('config', 'schemas', 'capabilities.json_schema').to_s

  belongs_to :team
  has_many :representations

  validates :capabilities, json: { schema: CAPABILITIES_JSON_SCHEMA }

  before_create :generate_token

  private def generate_token
    self.token = SecureRandom.uuid
  end
end
