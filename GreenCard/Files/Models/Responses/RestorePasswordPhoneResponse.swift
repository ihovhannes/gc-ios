//
// Created by Hovhannes Sukiasian on 25/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

/*

{
  "status" : "OK"
}

{
  "non_field_errors" : [
    "Пользователь не найден"
  ]
}

*/
struct RestorePasswordPhoneResponse {

    let status: String?
    var errors: [String?]?

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")

        status = json["status"].string

        if let errorsJson = json["non_field_errors"].array {
            errors = errorsJson.map({ $0.string })
        }
    }

    var isSuccess: Bool {
        if let status = status, status == "OK" {
            return true
        }
        return false
    }

}
