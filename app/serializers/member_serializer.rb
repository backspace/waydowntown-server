class MemberSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :lat, :lon
  belongs_to :team
end
