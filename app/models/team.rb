class Team < ApplicationRecord
  has_many :participations
  has_many :games, through: :participations
  has_many :incarnations, through: :games

  def token
    id # FIXME
  end
end
