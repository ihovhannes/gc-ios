//
//  Rx+UIView.swift
//  wrun-ios
//
//  Created by Appril on 25.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension UIGestureRecognizer {

  private struct UIGestureRecognizerRuntimeKeys {

    static var tag  = "\(#file)+\(#line)"
  }

  var tag: String? {
    get {
      return objc_getAssociatedObject(self, &UIGestureRecognizerRuntimeKeys.tag) as? String
    }
    set {
      guard let value = newValue else { return }
      let policy = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
      objc_setAssociatedObject(self, &UIGestureRecognizerRuntimeKeys.tag, value, policy)
    }
  }
}

fileprivate extension UIView {

  private struct UIViewRuntimeKeys {

    static var tag = "\(#file)+\(#line)"
  }

  var gestureRecognizerTap: UITapGestureRecognizer {
    var gestureRecognizerTap: UITapGestureRecognizer? = nil
    for case let gestureRecognizer as UITapGestureRecognizer in gestureRecognizers ?? [] {
      if gestureRecognizer.tag == UIViewRuntimeKeys.tag {
        gestureRecognizerTap = gestureRecognizer
      }
    }
    if gestureRecognizerTap == nil {
      gestureRecognizerTap = UITapGestureRecognizer()
      gestureRecognizerTap?.tag = UIViewRuntimeKeys.tag
      addGestureRecognizer(gestureRecognizerTap!)
    }
    return gestureRecognizerTap!
  }
}

extension Reactive where Base: UIView {

  func observableTap() -> Observable<Void> {
    base.isUserInteractionEnabled = true
    return base.gestureRecognizerTap.rx.event.asObservable().map({ _ in })
  }
}
