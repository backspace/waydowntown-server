class MemberSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  attributes :name, :lat, :lon, :last_subscribed, :last_unsubscribed
  belongs_to :team
end
