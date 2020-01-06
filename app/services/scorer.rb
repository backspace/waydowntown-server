class Scorer
  def initialize(game)
    @game = game
  end

  def call
    comparison = scoring == "closest" ? :min_by : :max_by

    highest = @game.participations.send(comparison){|p| calculate_participation_score(p) }[:score]
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
    if scoring == "highest_value"
      representation.result && representation.result["value"] ?
        representation.result["value"] : 0
    elsif scoring == "most_matches"
      goal = @game.incarnation.goal["values"]
      found = representation.result && representation.result["values"] ? representation.result["values"] : []

      matches = (goal & found)

      if representation.result
        representation.result["matches"] = matches
        representation.save
      end

      matches.length
    elsif scoring == "closest"
      goal = @game.incarnation.goal["value"]
      (goal - (representation.result && representation.result["value"] ?
        representation.result["value"] : 0)).abs
    end
  end

  protected def calculate_participation_score(participation)
    representing = participation.representations.select(&:representing)
    participation.score =
      representing.inject(0.0) {|sum, r| sum + calculate_representation_score(r) } / representing.length
  end

  protected def scoring
    @game.incarnation.concept.scoring
  end
end
