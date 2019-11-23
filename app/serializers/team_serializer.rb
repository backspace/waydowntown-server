class TeamSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :lat, :lon
end
