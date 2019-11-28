module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_team

    def connect
      self.current_team = find_verified_team
    end

    protected def find_verified_team
      team = Team.find_by(id: request.params[:token])

      reject_unauthorized_connection unless team
      team
    end
  end
end
