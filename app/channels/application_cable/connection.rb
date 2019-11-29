module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_team

    def connect
      self.current_team = find_verified_team
    end

    protected def find_verified_team
      member = Member.find_by(id: request.params[:token])

      reject_unauthorized_connection unless member
      member.team
    end
  end
end
