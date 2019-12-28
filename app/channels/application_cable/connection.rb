module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_member

    def connect
      self.current_member = find_verified_member
    end

    protected def find_verified_member
      member = Member.find_by(token: request.params[:token])

      reject_unauthorized_connection unless member
      member
    end
  end
end
