class GamesController < ApplicationController
  def index
    not_dismissed_games =
      Game.left_outer_joins(participations: :representations)
        .where(participations: {team: current_team})
        .where.not(participations: {aasm_state: 'dismissed'})

    # FIXME this didn’t quite work but something like it is probably possible
    games = not_dismissed_games.reject do |game|
      participation = game.participations.find_by(team: current_team)
      representation = participation.representations.find_by(member: current_member)
      representation && representation.archived?
    end

    render json: game_json(games)
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
    broadcast_to_teams(game, json)

    render json: json
  end

  def arrive
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.may_arrive?

    team_participation.arrive!

    if game.participations.all?(&:may_represent?)
      game.participations.each(&:represent!)
    end

    if game.participations.all?(&:may_schedule?)
      Scheduler.new(game).schedule
    else
      game.representing_ends_at = Time.current + 30.seconds
      game.save
      EndRepresentingStageJob.set(wait_until: game.representing_ends_at).perform_later(game)
    end

    json = game_json(game)
    broadcast_to_teams(game, json)

    render json: json
  end

  def represent
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.representing?

    team_participation.representations.find_by(member: current_member).update(representing: params[:representing])

    if game.participations.all?(&:may_schedule?)
      Scheduler.new(game).schedule
    end

    json = game_json(game)
    broadcast_to_teams(game, json)

    render json: json
  end

  def report
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.may_finish?

    member_representation = team_participation.representations.find_by(member: current_member)

    render json: {errors: [{status: "403"}]}, status: :forbidden and return unless member_representation && member_representation.representing?

    team_participation.finish
    team_participation.save

    permitted = params.permit([ "value" ])

    member_representation.result = permitted
    member_representation.save

    json = game_json(game)
    broadcast_to_teams(game, json)

    render json: json
  end

  def cancel
    game = Game.find(params[:id])

    game.participations.each(&:cancel!)

    json = game_json(game)
    broadcast_to_teams(game, json)

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

    render_conflict and return unless team_participation.finished?

    team_participation.representations.find_by(member: current_member).update(archived: true)

    render json: game_json(game)
  end

  protected def game_json(game)
    GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team', :'participations.team.members', :'participations.representations']).serializable_hash
  end

  protected def broadcast_to_teams(game, json)
    game.teams.each do |other_team|
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
