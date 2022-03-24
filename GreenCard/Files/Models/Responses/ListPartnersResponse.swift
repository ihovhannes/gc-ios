//
// Created by Hovhannes Sukiasian on 24/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import SwiftyJSON

struct ListPartnersResponse {


    var results: [PartnerInfo?]?

    init(data: Data) {
        let json = JSON(data: data)

        if let resultsJson = json["results"].array {
            results = resultsJson.map({ PartnerInfo(json: $0) })
        }
    }

}

//{
//    "logo_shares_black_bg_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2017\/12\/11\/25ch-azs-315x200-b.png",
//    "color" : "#007b33",
//    "id" : 1,
//    "logo_detail_page_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2017\/12\/22\/25ch-azs-370x182-c.png",
//    "logo_shares_white_bg_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2017\/12\/15\/25ch-azs-280x140-w.png",
//    "logo_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2015\/09\/08\/%D0%91%D0%B5%D0%B7%D1%8B%D0%BC%D1%8F%D0%BD%D0%BD%D1%8B%D0%B9_-05.png",
//    "name" : "Автозаправки «25 ЧАСОВ»",
//    "logo_map_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2017\/12\/11\/25ch-azs-168x160-marker.png"
//}

struct PartnerInfo {

    let id: Int64?
    let partnerName: String?
    let logoSrc: String?

    let logoDetailSrc: String?
    let detailColor: String?

    init(json: JSON) {
        id = json["id"].int64
        partnerName = json["name"].string
        logoSrc = json["logo_shares_black_bg_src"].string

        logoDetailSrc = json["logo_detail_page_src"].string
        detailColor = json["color"].string
    }

}
