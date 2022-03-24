import RxSwift

func observerEmpty<T>(with type: T.Type) -> AnyObserver<T> {
  return AnyObserver<T>.init(eventHandler: { _ in })
}
