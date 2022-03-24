//
// Created by Hovhannes Sukiasian on 28/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON


/*

{
  "next" : null,
  "previous" : null,
  "results" : [
    {
      "id" : 115,
      "partner_color" : "#545454",
      "partner_logo_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2015\/09\/01\/%D0%91%D0%B5%D0%B7%D1%8B%D0%BC%D1%8F%D0%BD%D0%BD%D1%8B%D0%B9-1-01-02.png",
      "partner_id" : 2,
      "phone" : "8(391)-285-43-82",
      "longitude" : "92.9297",
      "latitude" : "56.0606",
      "partner_name" : "Супермаркеты «Rosa»",
      "address" : "Комсомольский 3в",
      "store_id" : 65,
      "email" : null,
      "name" : "Супермаркет ROSA"
    }
  ],
  "count" : 32
}
*/


struct PartnerVendorsResponse {

    let list: [PartnerVendorItem]?

    init(data: Data) {
        let json = JSON(data: data)
//        log("\(json)")

        list = json["results"].array.flatMap { (results: [JSON]) in
            results.flatMap({ PartnerVendorItem(json: $0) })
        }
    }

    var isEmpty: Bool {
        if let list = list {
            let items = list.filter({ $0.longitude != nil && $0.latitude != nil})
            return items.count == 0
        }
        return true
    }

}

struct PartnerVendorItem {

    let vendorName: String?
    let address: String?
    let phone: String?
    let email: String?

    let longitude: Float?
    let latitude: Float?
    let logoSrc: String?

    init(json: JSON) {
        vendorName = json["name"].string
        address = json["address"].string
        phone = json["phone"].string
        email = json["email"].string


        longitude = json["longitude"].string.flatMap({ Float($0) })
        latitude = json["latitude"].string.flatMap({ Float($0) })
        logoSrc = json["partner_logo_src"].string
    }

}
