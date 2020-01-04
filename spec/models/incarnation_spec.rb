require 'rails_helper'

RSpec.describe Incarnation, type: :model do
  let!(:the_bay) { Location.create!(name: "The Bay", bounds: construct_multi_polygon([[ [ -97.1499285, 49.8899312 ], [ -97.1500505, 49.8901247 ], [ -97.150304, 49.8905355 ], [ -97.1504985, 49.8908497 ], [ -97.1504998, 49.8908726 ], [ -97.1504797, 49.8908868 ], [ -97.1497065, 49.8911663 ], [ -97.149671, 49.8911663 ], [ -97.1496515, 49.8911521 ], [ -97.1495992, 49.8910687 ], [ -97.1490943, 49.8901497 ], [ -97.1491502, 49.8901313 ], [ -97.1491815, 49.8901252 ], [ -97.1492655, 49.8901034 ], [ -97.1492701, 49.8901113 ], [ -97.149439, 49.8900673 ], [ -97.1498084, 49.8899713 ], [ -97.1498038, 49.8899636 ], [ -97.1499105, 49.889937 ], [ -97.1499285, 49.8899312 ] ]] ))}
  let!(:basement) { Location.create!(description: "The basement", parent: the_bay)}

  let!(:void) { Location.create!(description: "The void")}

  let!(:a_point_location_bay) { Location.create!(name: "The Bay", lat: 49.2, lon: -97.2, bounds: construct_multi_polygon([[ [ -97.1499285, 49.8899312 ], [ -97.1500505, 49.8901247 ], [ -97.150304, 49.8905355 ], [ -97.1504985, 49.8908497 ], [ -97.1504998, 49.8908726 ], [ -97.1504797, 49.8908868 ], [ -97.1497065, 49.8911663 ], [ -97.149671, 49.8911663 ], [ -97.1496515, 49.8911521 ], [ -97.1495992, 49.8910687 ], [ -97.1490943, 49.8901497 ], [ -97.1491502, 49.8901313 ], [ -97.1491815, 49.8901252 ], [ -97.1492655, 49.8901034 ], [ -97.1492701, 49.8901113 ], [ -97.149439, 49.8900673 ], [ -97.1498084, 49.8899713 ], [ -97.1498038, 49.8899636 ], [ -97.1499105, 49.889937 ], [ -97.1499285, 49.8899312 ] ]] ))}

  context "incarnation points" do
    it "chooses the incarnation’s latitude and longitude if they exist" do
      expect(Incarnation.new(lat: 49.1, lon: -97.1).point).to have_attributes({x: -97.1, y: 49.1})
    end

    it "chooses a location’s point over its bounds if it exists" do
      expect(Incarnation.new(location: a_point_location_bay).point).to have_attributes({x: -97.2, y: 49.2})
    end

    it "chooses the centroid of the closest location with bounds" do
      expect(Incarnation.new(location: basement).point).to have_attributes({x: -97.14979904147914, y: 49.89054312476751})
    end

    it "returns nil if no location has bounds" do
      expect(Incarnation.new(location: void).point).to be_nil
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
