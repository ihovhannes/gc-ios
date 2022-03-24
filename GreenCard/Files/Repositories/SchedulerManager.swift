//
//  QueueManager.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 10.01.2018.
//  Copyright © 2018 Appril. All rights reserved.
//

import RxSwift

class SchedulerManager {

    static let instance = SchedulerManager()
    
    let databaseScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: "database_scheduler"))
    let networkScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: "network_scheduler"))
}
