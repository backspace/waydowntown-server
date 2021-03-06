class IncarnationSerializer
  include FastJsonapi::ObjectSerializer
  set_type :incarnation
  belongs_to :concept

  attributes :questions, :credit, :lat, :lon
end
