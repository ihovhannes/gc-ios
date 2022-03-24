//
// Created by Hovhannes Sukiasian on 15/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

struct UpdateUserSubscribedResponse {

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")
    }

}
