class GamesController < ApplicationController
  def find
    team = Team.find_by(id: bearer_token)

    games = FindGames.new(team).call
    game = games.first
    game.save

    render json: GameSerializer.new(game, include: [:incarnation, :'incarnation.concept']).serializable_hash
  end

  private def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end
end
