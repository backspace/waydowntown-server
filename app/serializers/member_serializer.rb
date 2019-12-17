class MemberSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  attributes :name, :lat, :lon, :last_located, :last_subscribed, :last_unsubscribed, :capabilities
  belongs_to :team
end
