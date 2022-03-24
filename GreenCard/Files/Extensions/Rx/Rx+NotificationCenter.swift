import RxCocoa
import RxOptional
import RxSwift

extension Reactive where Base: NotificationCenter {

  func observe<T: NotificationRepresentable>(with type: T.Type) -> Observable<T> {
    return self
      .notification( T.notificationRepresentableName() )
      .map({ notification -> T? in
        let mappedValue: T? = T.notificationRepresentableMapping(notification)
        return mappedValue
      })
      .filterNil()
  }
}
