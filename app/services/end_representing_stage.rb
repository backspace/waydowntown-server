class EndRepresentingStage
  def initialize(game)
    @game = game
  end

  def call
    return if @game.begins_at

    unless @game.participations.all?(&:may_schedule?)
      @game.participations.reject(&:may_schedule?).each do |participation|
        if participation.representations.where(representing: true).any?
          participation.representations.where(representing: nil).update(representing: false)
        else
          undecided_representations = participation.representations.where(representing: nil)

          undecided_representations.each_with_index do |representation, i|
            representation.update(representing: i == 0)
          end
        end
      end
    end

    Scheduler.new(@game).schedule

    @game.teams.each do |team|
      TeamChannel.broadcast_to(team, {
        type: 'changes',
        content: @game.to_serializable_hash
      })
    end
  end
end
