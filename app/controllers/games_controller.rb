class GamesController < ApplicationController
  def index
    team = Member.find_by(id: bearer_token).team
    render json: GameSerializer.new(team.games, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team']).serializable_hash
  end

  def find
    team = Member.find_by(id: bearer_token).team

    games = FindGames.new(team).call
    game = games.first

    CreateProspectiveGame.new(team, game).call

    json = GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team']).serializable_hash

    render json: json, status: :created
  end

  def accept
    team = Member.find_by(id: bearer_token).team
    game = Game.find(params[:id])

    game.participations.where(team: team).each{|p| p.accept!}
    game.participations.where.not(team: team).each{|p| p.invite! if p.may_invite? }

    if game.participations.all?(&:may_converge?)
      game.participations.each(&:converge!)
    end

    json = GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team']).serializable_hash

    game.participations.where.not(team_id: team.id).map(&:team).each do |other_team|
      TeamChannel.broadcast_to(other_team, {
        type: 'changes',
        content: json
      })
    end

    render json: json
  end

  def arrive
    team = Member.find_by(id: bearer_token).team
    game = Game.find(params[:id])

    game.participations.where(team: team).each{|p| p.arrive!}

    if game.participations.all?(&:may_schedule?)
      game.participations.each(&:schedule!)

      current = Time.current
      game.begins_at = current + 30.seconds
      game.ends_at = current + 40.seconds

      game.save
    end

    json = GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team']).serializable_hash

    game.participations.where.not(team_id: team.id).map(&:team).each do |other_team|
      TeamChannel.broadcast_to(other_team, {
        type: 'changes',
        content: json
      })
    end

    render json: json
  end

  def report
    team = Member.find_by(id: bearer_token).team
    game = Game.find(params[:id])

    participation = game.participations.find_by(team: team)
    participation.finish
    participation.result = params[:result]
    participation.save

    json = GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team']).serializable_hash

    game.participations.where.not(team_id: team.id).map(&:team).each do |other_team|
      TeamChannel.broadcast_to(other_team, {
        type: 'changes',
        content: json
      })
    end

    render json: json
  end
end
