class MembersController < ApplicationController
  def update
    member = Member.find_by(id: bearer_token) # FIXME add handling for attempt to update other member?

    permitted = params.permit(data: { attributes: ["registration-id", "registration-type"] })
    new_attributes = permitted["data"]["attributes"].to_hash.each_with_object({}) do |(key, value), obj|
      obj[key.underscore] = value
    end

    member.update(new_attributes)
    render json: MemberSerializer.new(member).serializable_hash
  end
end
