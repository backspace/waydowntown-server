class GameSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :incarnation
  has_many :participations
end
