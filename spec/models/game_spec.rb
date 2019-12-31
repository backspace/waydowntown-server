require 'rails_helper'

RSpec.describe Game, type: :model do
  context "with compound directions" do
    it "joins the locations and adds a final period" do
      building = Location.new(name: "Building")
      upstairs = Location.new(parent: building, description: "Upstairs")

      incarnation = Incarnation.new(location: upstairs)

      expect(Game.new(incarnation: incarnation).directions).to eq "Building. Upstairs."
    end

    it "skips the final period when redundant" do
      building = Location.new(name: "Building")
      upstairs = Location.new(parent: building, description: "Go up the stairs.")

      incarnation = Incarnation.new(location: upstairs)

      expect(Game.new(incarnation: incarnation).directions).to eq "Building. Go up the stairs."
    end
  end
end
