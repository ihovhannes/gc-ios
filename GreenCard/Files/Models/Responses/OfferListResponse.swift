//
//  OfferListResponse.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 30.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import SwiftyJSON

struct OfferListResponse {
    
    let count: Int?
    var results: [ShareResponse?]?
    
    init(data: Data) {
        let json = JSON(data: data)
//        log("\(json)")
        
        count = json["count"].int
        if let resultsJson = json["results"].array {
            results = resultsJson.map({ ShareResponse(json: $0) })
        }

        let ids: [Int64]? = results.flatMap{ (array:[ShareResponse?]) in
            array.flatMap { (shareOpt: ShareResponse?) in
                shareOpt.flatMap { (share: ShareResponse) in
                    return share.id
                }
            }
        }
        log("ids = \(ids)")
    }

}
