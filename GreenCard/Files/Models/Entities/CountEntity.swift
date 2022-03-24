//
//  CountEntity.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 10.01.2018.
//  Copyright © 2018 Appril. All rights reserved.
//

import GRDB

class CountEntity: Record {

    static let shareCountId = 0
    static let vendorCountId = 1
    
    var id: Int = 0
    var count: Int = 0
    
    required init(row: Row) {
        super.init(row: row)
        id = row["id"]
        count = row["count"]
    }
    
    init(id: Int, count: Int) {
        super.init()
        self.id = id
        self.count = count
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["count"] = count
    }
    
    override class var databaseTableName: String {
        return "count"
    }
}
