class ParticipationSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :game
  belongs_to :team
  has_many :representations
  attributes :initiator, :winner

  attribute :state do |object|
    object.aasm_state
  end

  attribute :score do |object|
    object[:score]
  end
end
