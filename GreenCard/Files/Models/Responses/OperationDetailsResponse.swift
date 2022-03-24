//
// Created by Hovhannes Sukiasian on 08/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON


/*
{
    "total_price" : "983.92",
    "partner_logo_white_bg_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2017\/12\/11\/rosa-market-280x140-w.png",
    "date_of" : "1509636443",
    "address" : "Мира 10",
    "products" : [
        {
        "position_num" : "1",
        "accrued_bonuses" : "0.00",
        "debited_bonuses" : "0.00",
        "price" : "0.00",
        "count" : 1,
        "total_price" : "0.00",
        "name" : "ПАКЕТ МАЙКА ��НД Роса 30*60 18м"
        }
    ],
    "type" : "покупка",
    "accrued_bonuses" : "48.40",
    "vendor_name" : "Супермаркет ROSA, пр. Мира, 10",
    "debited_bonuses" : "0.92",
    "partner_color" : "#545454",
    "partner_logo_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2015\/09\/01\/%D0%91%D0%B5%D0%B7%D1%8B%D0%BC%D1%8F%D0%BD%D0%BD%D1%8B%D0%B9-1-01-02.png",
    "unique_id" : "00204141473068084334",
    "partner_logo_black_bg_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2017\/12\/11\/rosa-market-315x160-b.png",
    "partner_name" : "Сеть супермаркетов «Rosa»",
    "bonuses" : 47.48
}
*/

struct OperationDetailsResponse {

    let partnerLogoSrc: String?
    let address: String?
    let dateOf: String?
    let typeOf: String?
    let uniqueId: String?

    let totalPrice: String?
    let accruedBonuses: String?
    let debitedBonuses: String?

    var products: [OperationDetailsResponseItem]?

    init(data: Data) {
        let json = JSON(data: data)

        partnerLogoSrc = json["partner_logo_black_bg_src"].string
        address = json["address"].string
        dateOf = json["date_of"].string
        typeOf = json["type"].string
        uniqueId = json["unique_id"].string

        totalPrice = json["total_price"].string
        accruedBonuses = json["accrued_bonuses"].string
        debitedBonuses = json["debited_bonuses"].string

        if let productsJson = json["products"].array {
            products = productsJson.map({ OperationDetailsResponseItem(json: $0) })
                    .sorted(by: { (left, right) in
                        return (left.positionNum ?? 0) < (right.positionNum ?? 0)
                    })
        }
    }

}

struct OperationDetailsResponseItem {

    let positionNum: Int?
    let name: String?
    let count: Float?
    let price: String?
    let totalPrice: String?
    let accruedBonuses: String?
    let debitedBonuses: String?

    init(json: JSON) {
        if let positionNumStr = json["position_num"].string, let positionInt = Int(positionNumStr) {
            positionNum = positionInt
        } else {
            positionNum = nil
        }
        name = json["name"].string
        count = json["count"].float
        price = json["price"].string
        totalPrice = json["total_price"].string
        accruedBonuses = json["accrued_bonuses"].string
        debitedBonuses = json["debited_bonuses"].string
    }

}
