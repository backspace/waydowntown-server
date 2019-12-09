class AuthController < ApplicationController
  def find
    render json: MemberSerializer.new(current_member, include: [:team]).serializable_hash, status: :created
  end
end
