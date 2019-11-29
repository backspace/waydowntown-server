class Team < ApplicationRecord
  has_many :participations
  has_many :games, through: :participations
  has_many :incarnations, through: :games
  has_many :members
end
