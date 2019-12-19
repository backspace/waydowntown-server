CONCEPTS = YAML.load_file("#{Rails.root.to_s}/config/concepts.yml")

class Incarnation < ApplicationRecord
  belongs_to :location, optional: true
  has_many :games

  def concept
    if @concept
      @concept
    else
      yml = CONCEPTS[concept_id]

      if yml
        Concept.new(id: concept_id, name: yml["name"], duration: yml["duration"])
      else
        Concept.new(id: "unknown", name: "Unknown concept", duration: 10)
      end
    end
  end

  def concept=(concept)
    @concept = concept
  end
end
