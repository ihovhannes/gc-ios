//
//  BarButtonItem.swift
//  wrun-ios
//
//  Created by Appril on 18.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit

extension UIButton {

  enum Position {
    case left
    case right
  }

  static func with(title: String, image: UIImage, position: Position, width: CGFloat = 80 ) -> UIButton {
    let button = UIButton(type: .custom)
    button.setTitle(title, for: .normal)
    button.titleEdgeInsets = UIEdgeInsetsMake(0,
                                              position == .left ? 5 : 0,
                                              0,
                                              position == .right ? 5 : 0)
    button.setImage(image, for: .normal)
    button.frame = CGRect(x: 0, y: 0, width: width, height: 28)
    return button
  }

}
