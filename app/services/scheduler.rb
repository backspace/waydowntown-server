class Scheduler
  def initialize(game)
    @game = game
  end

  def schedule
    @game.participations.each(&:schedule!)

    current = Time.current
    delay = Rails.configuration.timing['scheduling']

    duration = @game.incarnation.duration || @game.incarnation.concept.duration

    @game.begins_at = current + delay
    @game.ends_at = current + delay + duration

    @game.save

    @game
  end
end
