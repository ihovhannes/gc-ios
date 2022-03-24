//
// Created by Hovhannes Sukiasian on 20/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit

class Consts {

    static let IPHONE_4_WIDTH: Double = 320
    static let IPHONE_4_HALF_WIDTH: Double = IPHONE_4_WIDTH / 2

    static let IPHONE_4_HEIGHT: Double = 480
    static let IPHONE_4_HALF_HEIGHT: Double = IPHONE_4_HEIGHT / 2

    static let IPHONE_5_WIDTH: Double = IPHONE_4_WIDTH
    static let IPHONE_5_HALF_WIDTH: Double = IPHONE_4_HALF_WIDTH

    static let IPHONE_5_HEIGHT: Double = 568
    static let IPHONE_5_HALF_HEIGHT: Double = IPHONE_5_HEIGHT / 2

    static func getScreenHeight() -> Double {
        return Double(UIScreen.main.bounds.height)
    }

    static func getTableHeaderHeight() -> Double {
        let screenHeight = Double(UIScreen.main.bounds.height)
        if screenHeight < IPHONE_5_HEIGHT {
            return IPHONE_4_HEIGHT
        } else {
            return IPHONE_5_HEIGHT
        }
    }

    static func getTableHeaderOffset(withFilters: Bool) -> Double {
        return withFilters ? -170 : 30
    }

    static let FILTER_TABLE_HEADER_ANIMATION_OFFSET: Double = 200
    static let FILTER_TABLE_HEADER_ANIMATION_DURATION: Double = 0.2

    static let TABLE_APPEAR_DURATION: Double = 0.4

    static let HEADER_ANIMATION_VELOCITY: CGFloat = 3
    static let TITLE_ANIMATION_VELOCITY: CGFloat = -8

}
