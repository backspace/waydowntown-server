class TeamsController < ApplicationController
  def index
    render json: TeamSerializer.new(Team.all).serializable_hash
  end
end
