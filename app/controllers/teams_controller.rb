class TeamsController < ApplicationController
  def index
    render json: TeamSerializer.new(Team.all, include: ['members']).serializable_hash
  end
end
