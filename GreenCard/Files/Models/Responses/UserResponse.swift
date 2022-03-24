//
//  UserResponse.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 31.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import SwiftyJSON

/*
{
  "non_field_errors" : [
    "Привязываемая карта не активирована."
  ]
}
*/

struct UserResponse {

    let id: Int64?
    let idString: String?
    let firstName: String?
    let fullName: String?
    let status: String?
    let bonuses: String?
    let phone: String?
    let bonusesToNextStatus: String?
    let push: Bool?
    let sms: Bool?
    let email: Bool?
    let isActive: Bool?

    var errors: [String?]?

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")

        id = json["id"].int64
        idString = json["id"].string
        firstName = json["first_name"].string
        fullName = json["full_name"].string
        status = json["current_status"].string
        bonuses = json["bns_balance"].string
        phone = json["phone"].string
        bonusesToNextStatus = json["bns_to_next_status"].string
        push = json["subscribed_to_push"].bool
        sms = json["subscribed_to_sms"].bool
        email = json["subscribed_to_email"].bool
        isActive = json["is_active"].bool

        if let errorsJson = json["non_field_errors"].array {
            errors = errorsJson.map({ $0.string })
        }
    }
}
