class Notifier
  def self.notify(team, message)
    apn = Houston::Client.send(Rails.env)

    team.members.select(&:registration_id).each do |member|
      notification = Houston::Notification.new(device: member.registration_id)
      notification.badge = 1
      notification.alert = message

      apn.push(notification)
    end
  end
end
