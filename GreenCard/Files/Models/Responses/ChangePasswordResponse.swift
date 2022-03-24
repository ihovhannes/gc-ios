//
// Created by Hovhannes Sukiasian on 15/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ChangePasswordResponse {

    var errors: [String?]?

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")

        if let errorsJson = json["non_field_errors"].array {
            errors = errorsJson.map({ $0.string })
        }

        if let errorsJson = json["errors"].array {
            errors = errorsJson.map({ $0.string })
        }
    }

    var isSuccess: Bool {
        return errors == nil
    }

}
