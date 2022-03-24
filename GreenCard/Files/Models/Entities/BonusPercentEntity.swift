//
//  BonusPercentEntity.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 09.01.2018.
//  Copyright © 2018 Appril. All rights reserved.
//

import GRDB

class BonusPercentEntity: Record {

    var id: Int64 = 0
    var partnerId: Int64 = 0
    var percents: Int64 = 0
    var status: String = ""
    
    required init(row: Row) {
        super.init(row: row)
        id = row["id"]
        partnerId = row["partner_id"]
        percents = row["percents"]
        status = row["status"]
    }
}
