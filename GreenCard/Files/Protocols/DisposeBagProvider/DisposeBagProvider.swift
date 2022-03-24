import RxSwift

protocol DisposeBagProvider: class {

  var disposeBag: DisposeBag { get }
}

private struct DisposeBagProviderRuntimeKey {

  static var key = "\(#file)+\(#line)"
}

extension DisposeBagProvider {

  var disposeBag: DisposeBag {
    if let value = objc_getAssociatedObject(self, &DisposeBagProviderRuntimeKey.key) as? DisposeBag {
      return value
    } else {
      let value = DisposeBag()
      objc_setAssociatedObject(self, &DisposeBagProviderRuntimeKey.key,
                               value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return value
    }
  }
}
