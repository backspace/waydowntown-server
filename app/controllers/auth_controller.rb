class AuthController < ApplicationController
  def find
    team = Team.find_by(id: bearer_token)

    if team
      render json: TeamSerializer.new(team).serializable_hash
    else
      render json: {}, status: :unauthorized
    end
  end
end
