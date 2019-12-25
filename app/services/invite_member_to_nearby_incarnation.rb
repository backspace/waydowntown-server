class InviteMemberToNearbyIncarnation
  def initialize(member)
    @member = member
  end

  def call
    incarnations = FindLocatedIncarnations.new(@member).call

    if incarnations && incarnations.first
      incarnation = incarnations.first
      location = incarnation.location

      team = @member.team
      Notifier.notify(team, "Are you near/in #{location.name}? Here’s an invitation")

      game = Game.create(incarnation: incarnation, teams: [team])
      game.participations.each(&:invite!)

      TeamChannel.broadcast_to(team, {
        type: 'changes',
        content: game.to_serializable_hash
      })
    end
  end
end
