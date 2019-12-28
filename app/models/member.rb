class Member < ApplicationRecord
  belongs_to :team
  has_many :representations

  before_create :generate_token

  private def generate_token
    self.token = SecureRandom.uuid
  end
end
