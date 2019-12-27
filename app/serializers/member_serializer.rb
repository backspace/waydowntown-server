class MemberSerializer
  include FastJsonapi::ObjectSerializer
  set_key_transform :dash
  attributes :name, :last_located, :last_subscribed, :last_unsubscribed, :capabilities, :device
  belongs_to :team

  attributes :admin, :lat, :lon, if: Proc.new {|record, params|
    current_member = params && params[:current_member]

    current_member && (current_member.admin? || current_member.id == record.id)
  }
end
