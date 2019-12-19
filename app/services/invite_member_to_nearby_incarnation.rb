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
      json = GameSerializer.new(game, include: [:incarnation, :'incarnation.concept', :participations, :'participations.team', :'participations.team.members', :'participations.representations']).serializable_hash

      TeamChannel.broadcast_to(team, {
        type: 'changes',
        content: json
      })
    end
  end
end
