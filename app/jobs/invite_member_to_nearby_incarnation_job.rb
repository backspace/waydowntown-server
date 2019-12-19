class InviteMemberToNearbyIncarnationJob < ApplicationJob
  queue_as :default

  def perform(member)
    InviteMemberToNearbyIncarnation.new(member).call
  end
end
