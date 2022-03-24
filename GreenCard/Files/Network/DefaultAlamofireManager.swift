//
//  DefaultAlamofireManager.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 13.01.2018.
//  Copyright © 2018 Appril. All rights reserved.
//

import Alamofire

class DefaultAlamofireManager: Alamofire.SessionManager {
    static let sharedManager: DefaultAlamofireManager = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 5
        return DefaultAlamofireManager(configuration: config)
    }()
}
