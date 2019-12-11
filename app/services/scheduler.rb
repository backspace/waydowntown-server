class Scheduler
  def initialize(game)
    @game = game
  end

  def schedule
    current = Time.current
    delay = 30.seconds

    duration = @game.incarnation.duration || @game.incarnation.concept.duration

    @game.begins_at = current + delay
    @game.ends_at = current + delay + duration

    @game
  end
end
