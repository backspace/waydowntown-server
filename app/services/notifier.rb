class Notifier
  def self.notify(team, message)
    apn = Houston::Client.send(Rails.env)
    fcm = FCM.new(ENV["FCM_SERVER_KEY"])

    team.members.select(&:registration_id).each do |member|
      if member.registration_type == "APNS"
        notification = Houston::Notification.new(device: member.registration_id)
        notification.badge = 1
        notification.alert = message

        apn.push(notification)
      elsif member.registration_type = "FCM"
        fcm.send([member.registration_id], options: {
          "notifications": {
            "body": message
          }
        })
      end
    end
  end
end
