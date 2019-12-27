class TeamsController < ApplicationController
  def index
    render json: TeamSerializer.new(Team.all, include: ['members'], params: { current_member: current_member }).serializable_hash
  end
end
