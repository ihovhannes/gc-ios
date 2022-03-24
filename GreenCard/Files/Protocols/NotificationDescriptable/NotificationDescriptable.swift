import Foundation

protocol NotificationDescriptable {

  static var name: Notification.Name { get }
}

struct NotificationDescriptor<A: NotificationDescriptable> {

  var map: (Notification) -> A?
}
