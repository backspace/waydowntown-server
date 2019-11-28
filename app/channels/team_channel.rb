class TeamChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_team
  end

  def unsubscribed
    # FIXME add online/offline status?
  end
end
