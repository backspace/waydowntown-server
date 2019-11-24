class GameSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :incarnation
end
