//
//  Updatable.swift
//  wrun-ios
//
//  Created by Appril on 08.06.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import Foundation

typealias UpdateableObject = (updates: Updates, animated: Bool)

protocol Updateable {

  func update(object: UpdateableObject, completion: ((Bool) -> Void)?)
}
