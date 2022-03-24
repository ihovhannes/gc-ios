//
// Created by Hovhannes Sukiasian on 06/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
{
  "results" : [
    {
      "card_num" : "3000012510058334",
      "is_locked" : false,
      "id" : 152115,
      "is_main" : true,
      "owner_first_name" : "Полина",
      "owner_phone" : "79082000913",
      "owner_status" : "Участник"
    },
    {
      "card_num" : "3000012510190580",
      "is_locked" : false,
      "id" : 559482,
      "is_main" : false,
      "owner_first_name" : "Дмитрий",
      "owner_phone" : "79538505010",
      "owner_status" : "Участник"
    }
  ]
}
*/

struct CardsListResponse {

    let list: [CardsListItem]?

    init(data: Data) {
        let json = JSON(data: data)
//        log("\(json)")

        list = json["results"].array.flatMap { (results: [JSON]) in
            results.flatMap({ CardsListItem(json: $0) })
        }
    }

}

struct CardsListItem {

    let cardNum: Int64?
    var isLocked: Bool
    let id: Int64?
    let isMain: Bool
    let ownerFirstName: String?
    let ownerPhone: String?
    let ownerStatus: String?

    init(json: JSON) {
        cardNum = json["card_num"].string.flatMap({ Int64($0) })
        isLocked = json["is_locked"].bool ?? false
        id = json["id"].int64
        isMain = json["is_main"].bool ?? false
        ownerFirstName = json["owner_first_name"].string
        ownerPhone = json["owner_phone"].string
        ownerStatus = json["owner_status"].string
    }

}
