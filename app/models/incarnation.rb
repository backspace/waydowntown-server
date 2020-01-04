CONCEPTS = YAML.load_file("#{Rails.root.to_s}/config/concepts.yml")

class Incarnation < ApplicationRecord
  extend Memoist

  belongs_to :location, optional: true
  has_many :games

  def concept
    if @concept
      @concept
    else
      yml = CONCEPTS[concept_id]

      if yml
        Concept.new(id: concept_id, name: yml["name"], duration: yml["duration"], scoring: yml["scoring"], capabilities: yml["capabilities"] || [])
      else
        Concept.new(id: "unknown", name: "Unknown concept", duration: 10, capabilities: [])
      end
    end
  end

  def concept=(concept)
    @concept = concept
  end

  def point
    location = self.location

    while location && !location.bounds
      location = location.parent
    end

    if location && location.bounds
      location.bounds.centroid
    else
      nil
    end
  end

  memoize :point

  def lat
    point.try(:y)
  end

  def lon
    point.try(:x)
  end
end
