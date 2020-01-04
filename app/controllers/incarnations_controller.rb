class IncarnationsController < ApplicationController
  def index
    incarnations = Incarnation.all

    json = IncarnationSerializer.new(incarnations, include: [:concept]).serializable_hash

    render json: json
  end
end
