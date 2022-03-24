//
// Created by Hovhannes Sukiasian on 05/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

extension UIView {

    func gestureArea(leftOffset: Int, topOffset: Int, rightOffset: Int, bottomOffset: Int) -> UIView {
        let gestureView = UIView()
        guard let superview = superview else {
            log("superview is nil for view: \(self)")
            return gestureView
        }
        superview.insertSubview(gestureView, aboveSubview: self)

        gestureView.backgroundColor = Palette.Common.transparentBackground.color
//        gestureView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        gestureView.snp.makeConstraints { gestureView in
            gestureView.leading.equalTo(self.snp.leading).offset(-1 * leftOffset)
            gestureView.top.equalTo(self.snp.top).offset(-1 * topOffset)
            gestureView.trailing.equalTo(self.snp.trailing).offset(rightOffset)
            gestureView.bottom.equalTo(self.snp.bottom).offset(bottomOffset)
        }
        return gestureView
    }

}
