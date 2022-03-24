//
// Created by Hovhannes Sukiasian on 04/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation


class WeakRef<T> where T: AnyObject, T: Hashable {

    private(set) weak var value: T?

    init(value: T?) {
        self.value = value
    }

    func isEqual(with: T) -> Bool {
        if let existing = value {
            return existing == with
        }
        return false
    }

}
