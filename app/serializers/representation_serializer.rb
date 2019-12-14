class RepresentationSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :member
  belongs_to :participation
  attributes :representing
end
