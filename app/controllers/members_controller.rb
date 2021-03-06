PERMITTED_CAPABILITIES = [
  "bluetooth",
  "camera",
  "decibels",
  "devicemotion",
  "location",
  "magnetometer",
  "ocr",

  "exertion",
  "height",
  "scents",
  "speed",
  "stairs",

  "fastNavigation",
]

PERMITTED_DEVICE = [
  "cordova",
  "model",
  "platform",
  "uuid",
  "version",
  "manufacturer",
  "isVirtual",
  "serial"
]

class MembersController < ApplicationController
  def update
    member = current_member # FIXME add handling for attempt to update other member?

    permitted = params.permit(data: {
      attributes: [
        "lat",
        "lon",
        "registration-id",
        "registration-type",
        capabilities: PERMITTED_CAPABILITIES,
        device: PERMITTED_DEVICE
      ] })

    render json: MemberSerializer.new(member, params: { current_member: current_member }).serializable_hash and return unless permitted["data"]["attributes"]

    new_attributes = permitted["data"]["attributes"].to_hash.each_with_object({}) do |(key, value), obj|
      obj[key.underscore] = value
    end

    if new_attributes["lat"] && new_attributes["lon"]
      new_attributes["last_located"] = Time.now
      InviteMemberToNearbyIncarnationJob.perform_later(member)
    end

    member.update(new_attributes)

    if member.valid?
      render json: MemberSerializer.new(member, params: { current_member: current_member }).serializable_hash
    else
      render json: {errors: [{status: "422"}]}, status: :unprocessable_entity
    end
  end

  def notify
    Notifier.notify_member(current_member, "A notification")
    head :created
  end
end
