class GamesController < ApplicationController
  def index
    render json: game_json(current_team.games)
  end

  def find
    team = current_team

    if params[:concept_id]
      incarnation = Incarnation.find_by(concept_id: params[:concept_id])

      teams = [team]

      if params[:team_id]
        teams << Team.find(params[:team_id])
      end

      game = Game.create(incarnation: incarnation, teams: teams)
    else
      games = FindGames.new(current_team).call
      game = games.first
    end

    CreateProspectiveGame.new(team, game).call

    json = game_json(game)

    render json: json, status: :created
  end

  def accept
    team = current_team
    game = Game.find(params[:id])

    game.participations.where(team: team).each{|p| p.accept!}
    game.participations.where.not(team: team).select(&:may_invite?).each do |p|
      p.invite!
      Notifier.notify(p.team, "#{team.name} invited you to a game")
    end

    if game.participations.all?(&:may_converge?)
      game.participations.each(&:converge!)
    end

    json = game_json(game)

    game.participations.where.not(team_id: team.id).map(&:team).each do |other_team|
      TeamChannel.broadcast_to(other_team, {
        type: 'changes',
        content: json
      })
    end

    render json: json
  end

  def arrive
    team = current_team
    game = Game.find(params[:id])

    game.participations.where(team: team).each{|p| p.arrive!}

    if game.participations.all?(&:may_schedule?)
      game.participations.each(&:schedule!)

      current = Time.current
      game.begins_at = current + 30.seconds
      game.ends_at = current + 40.seconds

      game.save
    end

    json = game_json(game)

    game.participations.where.not(team_id: team.id).map(&:team).each do |other_team|
      TeamChannel.broadcast_to(other_team, {
        type: 'changes',
        content: json
      })
    end

    render json: json
  end

  def report
    team = current_team
    game = Game.find(params[:id])

    participation = game.participations.find_by(team: team)
    participation.finish
    participation.result = params[:result]
    participation.save

    json = game_json(game)

    game.participations.where.not(team_id: team.id).map(&:team).each do |other_team|
      TeamChannel.broadcast_to(other_team, {
        type: 'changes',
        content: json
      })
    end

    render json: json
  end

  def cancel
    team = current_team
    game = Game.find(params[:id])

    game.participations.each(&:cancel!)

    json = game_json(game)

    game.participations.where.not(team_id: team.id).map(&:team).each do |other_team|
      TeamChannel.broadcast_to(other_team, {
        type: 'changes',
        content: json
      })
    end

    render json: json
  end

  def dismiss
    team = current_team
    game = Game.find(params[:id])

    game.participations.find_by(team: team).dismiss!

    render json: game_json(game)
  end

  protected def game_json(game)
    GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team']).serializable_hash
  end
end
