class TeamChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_member.team
  end
end
