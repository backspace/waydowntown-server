class TeamChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_member.team
    current_member.update_attributes(last_subscribed: Time.now)
  end

  def unsubscribed
    current_member.update_attributes(last_unsubscribed: Time.now)
  end
end
