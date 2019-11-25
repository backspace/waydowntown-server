class FindGames
  attr_accessor :initiator

  def initialize(initiator)
    @initiator = initiator
  end

  def call()
    (Incarnation.all - @initiator.incarnations).map do |incarnation|
      Team.all.without(@initiator).map do |other_team|
        Game.new(incarnation: incarnation, teams: [@initiator, other_team])
      end
    end.flatten
  end
end
