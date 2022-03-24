import UIKit

extension Optional where Wrapped == UICollectionView {

  var layoutOffset: CGFloat {
    switch self {
    case .some(let view):
      return view.contentOffset.y
    default:
      return 0.0
    }
  }

  var layoutCapacity: Int {
    switch self {
    case .some(let view):
      switch view.numberOfSections {
      case 1:
        return view.numberOfItems(inSection: 0)
      default:
        return 0
      }
    default:
      return 0
    }
  }

  var layoutHeight: CGFloat {
    switch self {
    case .some(let view):
      return view.bounds.height - view.contentInset.top - view.contentInset.bottom
    default:
      return 0.0
    }
  }

  var layoutWidth: CGFloat {
    switch self {
    case .some(let view):
      return view.bounds.width - view.contentInset.left - view.contentInset.right
    default:
      return 0.0
    }
  }
}
