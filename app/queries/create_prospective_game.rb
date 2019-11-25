class CreateProspectiveGame
  attr_accessor :initiator

  def initialize(initiator, game)
    @initiator = initiator
    @game = game
  end

  def call()
    @game.save!
    @game.participations.find_by(team_id: @initiator.id).update_attribute(:initiator, true)

    @game
  end
end
