class GamesController < ApplicationController
  def find
    team = Team.find_by(id: bearer_token)

    games = FindGames.new(team).call
    game = games.first

    CreateProspectiveGame.new(team, game).call

    json = GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team']).serializable_hash

    render json: json
  end

  def accept
    team = Team.find_by(id: bearer_token)
    game = Game.find(params[:id])

    game.participations.where(team: team).update_all(accepted: true)

    json = GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team']).serializable_hash

    game.participations.where.not(team_id: team.id).map(&:team).each do |other_team|
      TeamChannel.broadcast_to(other_team, {
        type: 'invitation',
        content: json
      })
    end

    render json: json
  end
end
