CONCEPTS = YAML.load_file("#{Rails.root.to_s}/config/concepts.yml")

class Incarnation < ApplicationRecord
  def concept
    if @concept
      @concept
    else
      yml = CONCEPTS[concept_id]

      if yml
        Concept.new(id: concept_id, name: yml["name"])
      else
        Concept.new(id: "unknown", name: "Unknown concept")
      end
    end
  end

  def concept=(concept)
    @concept = concept
  end
end
