//
// Created by Hovhannes Sukiasian on 06/02/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
 {
  "status" : "FAIL",
  "errors" : [
    "Пароль не был изменен, возможно вы неверно указали код из СМС сообщения"
  ]
}
*/

struct RestorePasswordChangeResponse {


    let status: String?
    var errors: [String?]?

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")

        status = json["status"].string

        if let errorsJson = json["non_field_errors"].array {
            errors = errorsJson.map({ $0.string })
        }

        if let errorsJson = json["errors"].array {
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
