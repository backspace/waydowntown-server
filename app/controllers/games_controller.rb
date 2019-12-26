class GamesController < ApplicationController
  def index
    return_archived = params[:archived] == "true"

    not_dismissed_games =
      Game.left_outer_joins(participations: :representations)
        .where(participations: {team: current_team})
        .where.not(participations: {aasm_state: 'dismissed'})

    filter_method = return_archived ? :select : :reject

    # FIXME this didn’t quite work but something like it is probably possible
    games = not_dismissed_games.send(filter_method) do |game|
      participation = game.participations.find_by(team: current_team)
      representation = participation.representations.find_by(member: current_member)

      representation && representation.archived?
    end

    render json: Game.to_serializable_hash(games)
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

    json = game.to_serializable_hash

    render json: json, status: :created
  end

  def accept
    team = current_team
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.may_accept?

    team_participation.accept!
    game.participations.where.not(team: team).select(&:may_invite?).each do |p|
      p.invite!
      Notifier.notify_team(p.team, "#{team.name} invited you to a game")
    end

    if game.participations.all?(&:may_converge?)
      game.participations.each(&:converge!)
    end

    json = game.to_serializable_hash
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

    json = game.to_serializable_hash
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

    json = game.to_serializable_hash
    broadcast_to_teams(game, json)

    render json: json
  end

  def report
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.may_score?

    member_representation = team_participation.representations.find_by(member: current_member)

    render json: {errors: [{status: "403"}]}, status: :forbidden and return unless member_representation && member_representation.representing?

    permitted = params.permit(:value, :values => [])

    member_representation.result = permitted
    member_representation.save

    team_participation_complete = team_participation.representations.all? {|r| !r.representing || r.result.present? }

    if team_participation_complete
      team_participation.score
      team_participation.save
    end

    json = game.to_serializable_hash

    if team_participation_complete
      broadcast_to_teams(game, json)
    end

    if game.participations.all?(&:scoring?)
      ScorerJob.perform_later(game)
    end

    render json: json
  end

  def cancel
    game = Game.find(params[:id])

    game.participations.each(&:cancel!)

    json = game.to_serializable_hash
    broadcast_to_teams(game, json)

    render json: json
  end

  def dismiss
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.may_dismiss?

    team_participation.dismiss!

    render json: game.to_serializable_hash
  end

  def archive
    game = Game.find(params[:id])

    render_conflict and return unless team_participation.finished?

    team_participation.representations.find_by(member: current_member).update(archived: true)

    render json: game.to_serializable_hash
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
