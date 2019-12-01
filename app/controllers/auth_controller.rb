class AuthController < ApplicationController
  def find
    member = Member.find_by(id: bearer_token)

    if member
      render json: MemberSerializer.new(member, include: [:team]).serializable_hash, status: :created
    else
      render json: {}, status: :unauthorized
    end
  end
end
