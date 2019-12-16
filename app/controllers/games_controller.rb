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

    render_conflict and return unless team_participation.may_accept?

    team_participation.accept!
    game.participations.where.not(team: team).select(&:may_invite?).each do |p|
      p.invite!
      Notifier.notify(p.team, "#{team.name} invited you to a game")
    end

    if game.participations.all?(&:may_converge?)
      game.participations.each(&:converge!)
    end

    json = game_json(game)
    broadcast_to_other_teams(game, json)

    render json: json
  end

  def arrive
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.may_arrive?

    team_participation.arrive!

    if game.participations.all?(&:may_represent?)
      game.participations.each(&:represent!)
    end

    json = game_json(game)
    broadcast_to_other_teams(game, json)

    render json: json
  end

  def represent
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.representing?

    team_participation.representations.find_by(member: current_member).update(representing: params[:representing])

    if game.participations.all?(&:may_schedule?)
      game.participations.each(&:schedule!)

      Scheduler.new(game).schedule

      game.save
    end

    json = game_json(game)
    broadcast_to_other_teams(game, json)

    render json: json
  end

  def report
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.may_finish?

    team_participation.finish
    team_participation.result = params[:result]
    team_participation.save

    json = game_json(game)
    broadcast_to_other_teams(game, json)

    render json: json
  end

  def cancel
    game = Game.find(params[:id])

    game.participations.each(&:cancel!)

    json = game_json(game)
    broadcast_to_other_teams(game, json)

    render json: json
  end

  def dismiss
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.may_dismiss?

    team_participation.dismiss!

    render json: game_json(game)
  end

  def archive
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.may_archive?

    team_participation.archive!

    render json: game_json(game)
  end

  protected def game_json(game)
    GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team', :'participations.team.members', :'participations.representations']).serializable_hash
  end

  protected def broadcast_to_other_teams(game, json)
    game.participations.where.not(team_id: current_team.id).map(&:team).each do |other_team|
      TeamChannel.broadcast_to(other_team, {
        type: 'changes',
        content: json
      })
    end
  end

  protected def team_participation
    @team_participation ||= Participation.find_by(team: current_team, game: Game.find(params[:id]))
  end

  protected def render_conflict
    render json: {errors: [{status: "409"}]}, status: :conflict
  end
end
