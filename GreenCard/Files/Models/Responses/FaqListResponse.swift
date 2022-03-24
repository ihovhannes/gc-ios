//
// Created by Hovhannes Sukiasian on 15/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import SwiftyJSON

struct FaqListResponse {

    var results: [FaqListItem?]?

    init(data: Data) {
        let json = JSON(data: data)

        if let resultsJson = json["results"].array {
            results = resultsJson.map({ FaqListItem(json: $0) })
        }
    }

}

struct FaqListItem {

    let id: Int64?
    let question: String?
    let answer: String?

    init(json: JSON) {
        id = json["id"].int64
        question = json["question"].string
        answer = json["answer"].string
    }

}
