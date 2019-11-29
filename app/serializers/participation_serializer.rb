class ParticipationSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :game
  belongs_to :team
  attributes :initiator

  attribute :state do |object|
    object.aasm_state
  end
end
