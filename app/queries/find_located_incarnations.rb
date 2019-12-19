class FindLocatedIncarnations
  def initialize(member)
    @member = member
  end

  def call()
    return [] unless @member.lat.present? && @member.lon.present?

    team = @member.team

    locations = Location.where("ST_DWithin(bounds, ST_Point(?, ?)::geography::geometry, 0.0001)", @member.lon, @member.lat)

    locations.map do |location|
      location.incarnations.select do |incarnation|
        incarnation.games.joins(:participations).where(participations: {team: team}).count == 0
      end
    end.flatten
  end
end
