//
//  Fonts.swift
//  wrun-ios
//
//  Created by Appril on 14.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//
import UIKit

enum Fonts {
  enum MainFonts: Fontable {
    case system

    func font(with size: CGFloat, _ weight: CGFloat) -> UIFont {
      switch self {
      case .system:
        return UIFont.systemFont(ofSize: size, weight:UIFont.Weight(rawValue: weight))
      }
    }
  }
}
