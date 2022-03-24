//
//  DatabaseService.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 09.01.2018.
//  Copyright © 2018 Appril. All rights reserved.
//

import GRDB
import RxGRDB
import RxSwift

class DatabaseService {
    
    static let instance = DatabaseService()
    
    let pool: DatabasePool
    
    private init() {
        do {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths.first ?? ""
            pool = try DatabasePool(path: path.appending("/greencard.db"))
            
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
        
        do {
            try DatabaseService.initialMigrator.migrate(pool)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    static var initialMigrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("create_user") { db in
            try db.create(table: "user", body: { t in
                t.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
                t.column("first_name", .text)
                t.column("status", .text)
                t.column("bonuses", .text)
                t.column("phone", .text)
                t.column("bonuses_to_next_status", .text)
                t.column("push", .boolean)
                t.column("sms", .boolean)
                t.column("email", .boolean)
                t.column("is_active", .boolean)
                t.column("update_date", .date)
            })
        }
        
        migrator.registerMigration("create_shares") { db in
            try db.create(table: "share", body: { t in
                t.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
                t.column("partner_id", .integer)
                t.column("is_special", .boolean)
                t.column("title", .text)
                t.column("start_date", .date)
                t.column("end_date", .date)
                t.column("horizontal_image", .text)
                t.column("vertical_image", .text)
                t.column("partner_logo", .text)
                t.column("partner_logo_white_bg", .text)
                t.column("partner_logo_black_bg", .text)
                t.column("partner_logo_map", .text)
                t.column("partner_color", .text)
                t.column("content", .text)
                t.column("update_date", .date)
            })
        }
        
        migrator.registerMigration("create_count") { db in
            try db.create(table: "count", body: { t in
                t.column("id", .integer).primaryKey(onConflict: .replace, autoincrement: false)
                t.column("count", .integer)
            })
        }
        
        return migrator
    }
}
