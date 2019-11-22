class FindGames
  attr_accessor :initiator

  def initialize(initiator)
    @initiator = initiator
  end

  def call()
    (Incarnation.all - @initiator.incarnations).map do |incarnation|
      Game.new(incarnation: incarnation)
    end
  end
end
