class GameSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  belongs_to :incarnation
  has_many :participations
  attributes :begins_at
end
