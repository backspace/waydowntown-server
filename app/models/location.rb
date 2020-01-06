class Location < ApplicationRecord
  include RatingsValidation

  belongs_to :parent, class_name: "Location", optional: true
  has_many :children, class_name: "Location", foreign_key: "parent_id"

  has_many :incarnations

  # Taken from https://stackoverflow.com/a/7339431/760389
  def ancestors
    [parent, parent.try(:ancestors)].compact.flatten
  end

  def hierarchy_capabilities
    (ancestors.map(&:capabilities) + capabilities).flatten.uniq
  end
end
