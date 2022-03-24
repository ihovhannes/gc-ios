//
//  AuthResponse.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 26.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import SwiftyJSON

struct AuthResponse {

    let token: String?
    var errors: [String?]?
    
    init(data: Data) {
        let json = JSON(data: data)
        token = json["token"].string
        if let errorsJson = json["non_field_errors"].array {
            errors = errorsJson.map({ $0.string })
        }
    }
}
