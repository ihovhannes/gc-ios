import RxCocoa
import RxSwift
import UIKit

extension UICollectionView: Updateable {

  func update(object: UpdateableObject, completion: ((Bool) -> Void)?) {
    DispatchQueue.main.async { [weak self] in
      switch object.animated {
      case true:
        self?.performBatchUpdates({
          self?.deleteItems(at: object.updates.row.delete)
          self?.insertItems(at: object.updates.row.insert)
          self?.reloadItems(at: object.updates.row.reload)
          self?.deleteSections(object.updates.section.delete)
          self?.insertSections(object.updates.section.insert)
        }, completion: completion)
      case false:
        self?.reloadData()
        completion?(true)
      }
    }
  }
}

extension Reactive where Base: UICollectionView {

  var observerUpdates: AnyObserver<UpdateableObject> {
    return UIBindingObserver(UIElement: base, binding: { (view: UICollectionView, object: UpdateableObject) in
      view.update(object: object, completion: nil)
    }).asObserver()
  }
}
