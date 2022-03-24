//
//  UserInfo.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 31.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Foundation

struct Account {

    let status: String
    let bonuses: String
    let bonusesToNextStatus: String

    let push: Bool
    let sms: Bool
    let email: Bool

    let isActive: Bool?
    
    init(apiObject: UserResponse) {
        status = apiObject.status ?? ""
        bonuses = apiObject.bonuses ?? "0.00"
        bonusesToNextStatus = apiObject.bonusesToNextStatus ?? "0.0"

        isActive = apiObject.isActive

        push = apiObject.push ?? false
        sms = apiObject.sms ?? false
        email = apiObject.email ?? false
    }
    
    init(userEntity: UserEntity) {
        status = userEntity.status ?? ""
        bonuses = userEntity.bonuses ?? ""
        bonusesToNextStatus = userEntity.bonusesToNextStatus ?? ""

        isActive = userEntity.isActive

        push = userEntity.push
        sms = userEntity.sms
        email = userEntity.email
    }
}
