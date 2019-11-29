class CreateProspectiveGame
  attr_accessor :initiator

  def initialize(initiator, game)
    @initiator = initiator
    @game = game
  end

  def call()
    @game.save!
    initiator_participation = @game.participations.find_by(team_id: @initiator.id)
    initiator_participation.initiator = true
    initiator_participation.invite
    initiator_participation.save

    @game
  end
end
