//
//  GreencardError.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 30.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Foundation

enum GreencardError: Error {
    case unauthorized
    case unknown
    case network
    case inResponse(msg: String)
}
