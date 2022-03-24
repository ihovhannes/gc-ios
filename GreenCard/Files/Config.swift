//
//  Config.swift
//  wrun-ios
//
//  Created by Hovhannes Sukiasian on 10.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import UIKit

class Config: NSObject {

    static let sharedInstance = Config()
    var configs: [String: Any]!
    override init() {
        let current = Bundle.main.object(forInfoDictionaryKey: "Config") as? String
        let path = Bundle.main.path(forResource: "Config", ofType: "plist")
        configs = NSDictionary(contentsOfFile: path!)?.object(forKey: current!) as? Dictionary
    }
}

extension Config {
    func shouldUseFabric() -> Bool {
        return configs["shouldUseFabric"] as? Bool ?? false
    }
    
    func apiUrl() -> URL {
        guard let url = configs["apiUrl"] as? String else { fatalError("No API url found!") }
        return URL(string: url)!
    }
}
