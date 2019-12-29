class GameSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  belongs_to :incarnation
  has_many :participations
  attributes :representing_ends_at, :begins_at, :ends_at, :directions

  attribute :duration do |object|
    object.incarnation.duration || object.incarnation.concept.duration
  end
end
