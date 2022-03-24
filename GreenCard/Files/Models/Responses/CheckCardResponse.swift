//
// Created by Hovhannes Sukiasian on 15/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
{
  "non_field_errors" : [
    "Неправильный номер или код карты"
  ]
}

{
  "non_field_errors" : [
    "Эта карта уже зарегистрирована"
  ]
}

{
  "is_valid" : true,
  "is_registered" : false
}

*/

struct CheckCardResponse {

    let isValid: Bool?
    let isRegistered: Bool?
    var errors: [String?]?

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")

        isValid = json["is_valid"].bool
        isRegistered = json["is_registered"].bool

        if let errorsJson = json["non_field_errors"].array {
            errors = errorsJson.map({ $0.string })
        }
    }

}
