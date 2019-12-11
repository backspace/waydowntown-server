class Scheduler
  def initialize(game)
    @game = game
  end

  def schedule
    current = Time.current
    delay = 30.seconds

    @game.begins_at = current + delay
    @game.ends_at = current + delay + @game.incarnation.concept.duration

    @game
  end
end
