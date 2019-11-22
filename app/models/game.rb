class Game < ApplicationRecord
  belongs_to :incarnation
  has_many :participations
  has_many :teams, through: :participations
end
