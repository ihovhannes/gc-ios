import Foundation

protocol NotificationRepresentable {

  static func notificationRepresentableMapping(_ notification: Notification) -> Self?
  static func notificationRepresentableName() -> Notification.Name
}
