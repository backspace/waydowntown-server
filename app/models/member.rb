class Member < ApplicationRecord
  belongs_to :team

  def token
    id # FIXME
  end
end
