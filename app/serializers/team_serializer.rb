class TeamSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :lat, :lon
  has_many :members
end
