//
//  ExtensionNavigationController.swift
//  wrun-ios
//
//  Created by Appril on 26.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit

extension UINavigationController {
  public func pushViewController(
    _ viewController: UIViewController,
    animated: Bool,
    completion: @escaping () -> Void) {
    pushViewController(viewController, animated: animated)

    guard animated, let coordinator = transitionCoordinator else {
      completion()
      return
    }

    coordinator.animate(alongsideTransition: nil) { _ in completion() }
  }
}
