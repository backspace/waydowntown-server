class PresenceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "presence_channel"
    current_member.update_attributes(last_subscribed: Time.now)

    json = MemberSerializer.new(current_member).serializable_hash
    ActionCable.server.broadcast "presence_channel", {type: "changes", content: json}
  end

  def unsubscribed
    current_member.update_attributes(last_unsubscribed: Time.now)

    json = MemberSerializer.new(current_member).serializable_hash
    ActionCable.server.broadcast "presence_channel", {type: "changes", content: json}
  end
end
