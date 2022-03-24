//
//  UserRealmModel.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 31.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import GRDB

class UserEntity: Record {

    var id: Int64 = 0
    var firstName: String?
    var status: String?
    var bonuses: String?
    var phone: String?
    var bonusesToNextStatus: String?
    var push: Bool = false
    var sms: Bool = false
    var email: Bool = false
    var isActive: Bool = false
    var updateDate: Date = Date()

    override init() {
        super.init()
    }

    required init(row: Row) {
        super.init(row: row)
        id = row["id"]
        firstName = row["first_name"]
        status = row["status"]
        bonuses = row["bonuses"]
        phone = row["phone"]
        bonusesToNextStatus = row["bonuses_to_next_status"]
        push = row["push"]
        sms = row["sms"]
        email = row["email"]
        isActive = row["is_active"]
        updateDate = row["update_date"]
    }
    
    init(response: UserResponse) {
        super.init()
        id = response.id ?? 0
        firstName = response.firstName
        status = response.status
        bonuses = response.bonuses
        phone = response.phone
        bonusesToNextStatus = response.bonusesToNextStatus
        push = response.push ?? false
        sms = response.sms ?? false
        email = response.email ?? false
        isActive = response.isActive ?? false
    }
    
    override class var databaseTableName: String {
        return "user"
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["first_name"] = firstName
        container["status"] = status
        container["bonuses"] = bonuses
        container["phone"] = phone
        container["bonuses_to_next_status"] = bonusesToNextStatus
        container["push"] = push
        container["sms"] = sms
        container["email"] = email
        container["is_active"] = isActive
        container["update_date"] = updateDate
    }
}
