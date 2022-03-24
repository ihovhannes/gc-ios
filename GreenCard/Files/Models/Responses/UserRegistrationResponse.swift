//
// Created by Hovhannes Sukiasian on 15/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON


/*
{
  "card_num" : [
    "Убедитесь, что в этом пол�� как минимум 16 символов."
  ],
  "card_code" : [
    "Убедитесь, что в этом поле как минимум 4 символов."
  ]
}

{
  "non_field_errors" : [
    "Неправильный номер или код карты"
  ]
}

 // -- Success

{
    "phone": "9080243307",
    "card_num": "3000012510285175"
}

// -- Fields

    @SerializedName("first_name")
    @SerializedName("full_name")
    @SerializedName("phone")
    @SerializedName("card_num")
    @SerializedName("bns_balance")
    @SerializedName("bns_to_next_status")
    @SerializedName("current_status")
    @SerializedName("password")
    @SerializedName("subscribed_to_push")
    @SerializedName("subscribed_to_email")
    @SerializedName("subscribed_to_sms")
    @SerializedName("is_active")



*/


struct UserRegistrationResponse {

    let phone: String?
    let cardNum: String?
    var errors: [String?]?

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")

        phone = json["phone"].string
        cardNum = json["card_num"].string

        if let errorsJson = json["non_field_errors"].array {
            errors = errorsJson.map({ $0.string })
        }
    }

    var isSuccess: Bool {
        return phone != nil && cardNum != nil
    }

}
