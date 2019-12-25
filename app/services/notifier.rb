class Notifier
  def self.notify_team(team, message)
    team.members.each do |member|
      begin
        self.notify_member(member, message)
      rescue StandardError => e
        Raven.capture_exception(e)
      end
    end
  end

  def self.notify_member(member, message)
    return unless member.registration_id.present?

    if member.registration_type == "APNS"
      notification = Houston::Notification.new(device: member.registration_id)
      notification.badge = 1
      notification.alert = message

      self.apn.push(notification)
    elsif member.registration_type = "FCM"
      self.fcm.send([member.registration_id], options: {
        "notifications": {
          "body": message
        }
      })
    end
  end

  def self.apn
    @@apn ||= Houston::Client.send(Rails.env)
  end

  def self.fcm
    @@fcm ||= FCM.new(ENV["FCM_SERVER_KEY"])
  end
end
