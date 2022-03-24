//
// Created by Hovhannes Sukiasian on 20/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import UIKit


extension UIView {

    var isShown: Bool {
        get {
            return !self.isHidden
        }
        set {
            self.isHidden = !newValue
        }
    }

}
