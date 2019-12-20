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

    # FIXME fromish GameController#represent

    @game.participations.each(&:schedule!)

    Scheduler.new(@game).schedule

    @game.save

    json = GameSerializer.new(@game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team', :'participations.team.members', :'participations.representations']).serializable_hash

    @game.teams.each do |team|
      TeamChannel.broadcast_to(team, {
        type: 'changes',
        content: json
      })
    end
  end
end
