//
// Created by Hovhannes Sukiasian on 16/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

struct UserActivateResponse {

    let isActive: Bool?
    var errors: [String?]?

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")

        isActive = json["is_active"].bool

        if let errorsJson = json["non_field_errors"].array {
            errors = errorsJson.map({ $0.string })
        }

        if let errorsJson = json["errors"].array {
            errors = errorsJson.map({ $0.string })
        }
    }

    var isSuccess: Bool {
        if let isActive = isActive, isActive == true {
            return true
        }
        return false
    }

}
