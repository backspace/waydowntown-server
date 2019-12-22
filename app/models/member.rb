class Member < ApplicationRecord
  belongs_to :team
  has_many :representations

  def token
    id # FIXME
  end
end
