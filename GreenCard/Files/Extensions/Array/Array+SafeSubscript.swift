//
//  Array+SafeSubscript.swift
//  wrun-ios
//
//  Created by Appril on 30.06.17.
//  Copyright © 2017 Appril. All rights reserved.
//

extension Array {
  subscript (safe index: Array.Index) -> Array.Iterator.Element? {
    return index >= self.startIndex && index < self.endIndex ? self[index] : nil
  }
}
