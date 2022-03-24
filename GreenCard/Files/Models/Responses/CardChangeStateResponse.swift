//
// Created by Hovhannes Sukiasian on 06/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

struct CardChangeStateResponse {

    // non_field_errors
    let nonFieldError: [String]?

    // is_changed
    let isChanged: Bool

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")

        nonFieldError = json["non_field_errors"].array.flatMap{ (list: [JSON]) in
            list.flatMap({$0.string})
        }
        isChanged = json["is_changed"].bool ?? false

    }


}
