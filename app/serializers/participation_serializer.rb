class ParticipationSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :game
  belongs_to :team
  attributes :initiator
end
