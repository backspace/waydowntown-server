class GamesController < ApplicationController
  def find
    team = Team.find_by(id: bearer_token)

    games = FindGames.new(team).call
    game = games.first

    CreateProspectiveGame.new(team, game).call

    json = GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team']).serializable_hash

    game.participations.reject(&:initiator).map(&:team).each do |other_team|
      TeamChannel.broadcast_to(other_team, {
        type: 'invitation',
        content: json
      })
    end

    render json: json
  end
end
