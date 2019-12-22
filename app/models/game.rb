class Game < ApplicationRecord
  belongs_to :incarnation
  has_many :participations
  has_many :teams, through: :participations
  has_many :representations, through: :participations

  def winners
    participations.where(winner: true).map(&:team)
  end
end
