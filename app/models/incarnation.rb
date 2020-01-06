class Incarnation < ApplicationRecord
  extend Memoist

  belongs_to :location, optional: true
  has_many :games

  def capabilities_raw
    self.capabilities.join("\n") unless self.capabilities.nil?
  end

  def capabilities_raw=(values)
    self.capabilities = []
    self.capabilities = values.split("\n")
  end

  def concept
    if @concept
      @concept
    else
      if concept_id
        yml = Rails.configuration.concepts[concept_id]
        Concept.new(id: concept_id, name: yml[:name], duration: yml[:duration], scoring: yml[:scoring], capabilities: yml[:capabilities] || [])
      else
        Concept.new(id: "unknown", name: "Unknown concept", duration: 10, capabilities: [])
      end
    end
  end

  def concept=(concept)
    @concept = concept
  end

  def point
    return RGeo::Geos.factory(srid: 4326).point(record_lon, record_lat) if record_lat.present? && record_lon.present?

    location = self.location

    while location && !location.bounds && (!location.lat.present? || !location.lon.present?)
      location = location.parent
    end

    if location
      if location.lat.present? && location.lon.present?
        RGeo::Geos.factory(srid: 4326).point(location.lon, location.lat)
      else
        location.bounds.centroid
      end
    else
      nil
    end
  end

  memoize :point

  def lat
    record_lat || point.try(:y)
  end

  def lon
    record_lon || point.try(:x)
  end

  private def record_lat
    read_attribute(:lat)
  end

  private def record_lon
    read_attribute(:lon)
  end
end
