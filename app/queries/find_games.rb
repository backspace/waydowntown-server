class FindGames
  attr_accessor :initiator

  def initialize(initiator)
    @initiator = initiator
  end

  def call()
    playable_unplayed_incarnations.map do |incarnation|
      Team.all.without(@initiator).select{|team| team.can_play? incarnation}.map do |other_team|
        Game.new(incarnation: incarnation, teams: [@initiator, other_team])
      end
    end.flatten
  end

  private def playable_unplayed_incarnations
    (Incarnation.all - @initiator.incarnations).select do |incarnation|
      @initiator.can_play? incarnation
    end
  end
end
