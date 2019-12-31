class Team < ApplicationRecord
  has_many :participations
  has_many :games, through: :participations
  has_many :incarnations, through: :games
  has_many :members

  def capabilities
    all_capabilities = members.map(&:capabilities)
    all_keys = all_capabilities.map(&:keys).flatten.uniq

    Hash[all_keys.map{|key| [key, all_capabilities.all? {|capabilities| capabilities[key] == true }]}]
  end

  def can_play?(incarnation)
    location = incarnation.location || Location.new
    concept_incarnation_and_location_capabilities = (
      incarnation.concept.capabilities +
      incarnation.capabilities +
      location.hierarchy_capabilities
    ).uniq

    return concept_incarnation_and_location_capabilities.all? do |capability|
      capabilities[capability]
    end
  end
end
