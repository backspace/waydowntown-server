class EndRepresentingStageJob < ApplicationJob
  queue_as :default

  def perform(game)
    EndRepresentingStage.new(game).call
  end
end
