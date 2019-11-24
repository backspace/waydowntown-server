class IncarnationSerializer
  include FastJsonapi::ObjectSerializer
  set_type :incarnation
  belongs_to :concept
end
