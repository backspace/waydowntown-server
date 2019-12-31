class Scorer
  def initialize(game)
    @game = game
  end

  def call
    highest = @game.participations.max_by{|p| calculate_participation_score(p) }[:score]
    @game.participations.select{|p| highest == p[:score] }.each{|p| p.winner = true && p.save }

    @game.participations.each(&:finish!)

    @game.teams.each do |team|
      TeamChannel.broadcast_to(team, {
        type: 'changes',
        content: @game.to_serializable_hash
      })
    end

    @game
  end

  protected def calculate_representation_score(representation)
    if @game.incarnation.concept.scoring == "highest_value"
      representation.result && representation.result["value"] ?
        representation.result["value"] : 0
    elsif @game.incarnation.concept.scoring == "most_matches"
      goal = @game.incarnation.goal["values"]
      found = representation.result && representation.result["values"] ? representation.result["values"] : []

      matches = (goal & found)

      if representation.result
        representation.result["matches"] = matches
        representation.save
      end

      matches.length
    end
  end

  protected def calculate_participation_score(participation)
    representing = participation.representations.select(&:representing)
    participation.score =
      representing.inject(0.0) {|sum, r| sum + calculate_representation_score(r) } / representing.length
  end
end
