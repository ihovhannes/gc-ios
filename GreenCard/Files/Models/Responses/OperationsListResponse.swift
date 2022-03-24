//
// Created by Hovhannes Sukiasian on 06/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

struct OperationsListResponse {

    var results: [OperationItem?]?
    var count: Int?

    init(data: Data) {
        let json = JSON(data: data)

        count = json["count"].int
        if let resultsJson = json["results"].array {
            results = resultsJson.map({ OperationItem(json: $0) })
        }
    }

}


//{
//    "accrued_bonuses" : "0.00",
//    "vendor_name" : "Ба�� 25 ЧАСОВ, ул. Маерчака, 119",
//    "partner_name" : "Автомоечные комплексы «25 часов»",
//    "debited_bonuses" : "44.98",
//    "unique_id" : "00106060673383288004",
//    "date_of" : "1512353280",
//    "partner_logo_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2015\/09\/08\/%D0%91%D0%B5%D0%B7%D1%8B%D0%BC%D1%8F%D0%BD%D0%BD%D1%8B%D0%B9_-06.png",
//    "bonuses" : "-44.98",
//    "total_price" : "45.00",
//    "partner_color" : "#1E90FF"
//}

struct OperationItem {

    let uniqueId: String?
    let vendorName: String?
    let bonuses: String?
    let totalPrice: String?
    let dateOf: String?

    let time: String
    let day: String

    init(json: JSON) {
        uniqueId = json["unique_id"].string
        vendorName = json["vendor_name"].string
        bonuses = json["bonuses"].string
        totalPrice = json["total_price"].string
        dateOf = json["date_of"].string

        if let dateString = dateOf, let dateNumber = Double(dateString) {
            let date = Date(timeIntervalSince1970: dateNumber)
            let formatter = DateFormatter.init()
            formatter.dateFormat = "HH:mm"
            time = formatter.string(from: date)

            formatter.dateFormat = "dd / MM / yy"
            day = formatter.string(from: date)
        } else {
            time = ""
            day = ""
        }
    }

}
