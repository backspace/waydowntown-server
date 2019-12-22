class ScorerJob < ApplicationJob
  queue_as :default

  def perform(game)
    Scorer.new(game).call
  end
end
