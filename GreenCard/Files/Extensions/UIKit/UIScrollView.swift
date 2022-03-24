//
// Created by Hovhannes Sukiasian on 02/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {

    var showsScrollIndicator: Bool {
        get {
            return showsHorizontalScrollIndicator || showsVerticalScrollIndicator
        }
        set {
            self.showsHorizontalScrollIndicator = newValue
            self.showsVerticalScrollIndicator = newValue
        }
    }

}
