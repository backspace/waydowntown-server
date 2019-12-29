class Game < ApplicationRecord
  belongs_to :incarnation
  has_many :participations
  has_many :teams, through: :participations
  has_many :representations, through: :participations

  def winners
    participations.where(winner: true).map(&:team)
  end

  def directions
    if incarnation.location
      location = incarnation.location
      location_directions = []

      while location
        location_directions << (location.name || location.description)
        location = location.parent
      end

      location_directions.reverse.join(". ") + "."
    else
      "FIXME"
    end
  end

  def to_serializable_hash
    GameSerializer.new(self, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team', :'participations.team.members', :'participations.representations']).serializable_hash
  end

  def self.to_serializable_hash(games)
    GameSerializer.new(games, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team', :'participations.team.members', :'participations.representations']).serializable_hash
  end
end
