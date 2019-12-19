RSpec.describe FindLocatedIncarnations do
  subject { described_class.new(member).call() }

  let!(:the_bay) { Location.create!(name: "The Bay", bounds: construct_multi_polygon([[ [ -97.1499285, 49.8899312 ], [ -97.1500505, 49.8901247 ], [ -97.150304, 49.8905355 ], [ -97.1504985, 49.8908497 ], [ -97.1504998, 49.8908726 ], [ -97.1504797, 49.8908868 ], [ -97.1497065, 49.8911663 ], [ -97.149671, 49.8911663 ], [ -97.1496515, 49.8911521 ], [ -97.1495992, 49.8910687 ], [ -97.1490943, 49.8901497 ], [ -97.1491502, 49.8901313 ], [ -97.1491815, 49.8901252 ], [ -97.1492655, 49.8901034 ], [ -97.1492701, 49.8901113 ], [ -97.149439, 49.8900673 ], [ -97.1498084, 49.8899713 ], [ -97.1498038, 49.8899636 ], [ -97.1499105, 49.889937 ], [ -97.1499285, 49.8899312 ] ]] ))}
  let!(:newport) { Location.create!(name: "Newport Centre", bounds: construct_multi_polygon([[ [ -97.1449366, 49.8925952 ], [ -97.1449036, 49.8925875 ], [ -97.1445965, 49.892657 ], [ -97.1445951, 49.8926756 ], [ -97.1446983, 49.8928599 ], [ -97.1447393, 49.8929413 ], [ -97.1447648, 49.8929521 ], [ -97.1450658, 49.8928864 ], [ -97.1450819, 49.8928687 ], [ -97.1449366, 49.8925952 ] ]] ) )}

  let!(:member) { Member.create(name: 'me', team: team) }
  let(:team) { Team.create(name: 'us') }

  let(:the_bay_played_incarnation) { Incarnation.create(location: the_bay) }
  let!(:the_bay_played_game) { Game.create(incarnation: the_bay_played_incarnation, teams: [team])}

  let!(:the_bay_unplayed_incarnation) { Incarnation.create(location: the_bay) }

  let!(:newport_incarnation) { Incarnation.create(location: newport) }

  it "ignores a member with no location" do
    expect(subject).to be_empty
  end

  context "when the member is within a location" do
    before do
      member.update(lat: 49.890619, lon: -97.149759)
    end

    it "finds an unplayed incarnation within it" do
      expect(subject).to include( the_bay_unplayed_incarnation )
      expect(subject).not_to include( the_bay_played_incarnation )
      expect(subject).not_to include( newport_incarnation )
    end
  end

  context "when the member is just outside a location" do
    before do
      member.update(lat: 49.892862, lon: -97.144672)
    end

    it "finds an unplayed incarnation within in" do
      expect(subject).not_to include( the_bay_unplayed_incarnation )
      expect(subject).not_to include( the_bay_played_incarnation )
      expect(subject).to include( newport_incarnation )
    end
  end

  context "when the member is farther outside a location" do
    before do
      member.update(lat: 49.892982, lon: -97.144464)
    end

    it "finds nothing" do
      expect(subject).to be_empty
    end
  end
end

def construct_multi_polygon(array_array_points)
  f = RGeo::Geos.factory(srid: 4326)

  array_array_geopoints = array_array_points.map do |array_points|
    array_points.map{|p| f.point(*p)}
  end

  array_linestrings = array_array_geopoints.map do |array_geopoints|
    f.line_string(array_geopoints)
  end

  array_polygons = array_linestrings.map{|ls| f.polygon(ls) }

  f.multi_polygon(array_polygons)
end
