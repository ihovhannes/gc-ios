//
// Created by Hovhannes Sukiasian on 22/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON


//{
//    "logo_map_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2017\/12\/11\/rosa-market-315x160-marker.png",
//    "logo_shares_white_bg_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2017\/12\/11\/rosa-market-280x140-w.png",
//    "name" : "Супер��аркеты «Rosa»",
//    "description" : "<p style=\"text-align: center;\">Получайте от 5 до 15% скидки в виде бонусов на вашу Гринкарту. Постоянные акции и специальные предложения легко увеличат ваш бонусный счет.<\/p>",
//    "photos" : [
//              "http:\/\/api.green-bonus.ru\/data\/partners\/2015\/09\/03\/IMG_2168_1024_1.jpg"
//              ],
//    "color" : "#545454",
//    "video_code" : "<iframe width=\"1280\" height=\"718\" src=\"https:\/\/www.youtube.com\/embed\/Q1-WI-FW2qk\" frameborder=\"0\" allowfullscreen><\/iframe>",
//    "bns_percents" : [
//                          {
//                                "status" : "Участник",
//                                "percents" : 5
//                          },
//                          {
//                                 "status" : "Серебряный",
//                                 "percents" : 8
//                          },
//                          {
//                                 "status" : "Золотой",
//                                 "percents" : 10
//                          },
//                          {
//                                 "status" : "Платиновый",
//                                 "percents" : 15
//                          }
//              ],
//    "id" : 2,
//    "logo_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2015\/09\/01\/%D0%91%D0%B5%D0%B7%D1%8B%D0%BC%D1%8F%D0%BD%D0%BD%D1%8B%D0%B9-1-01-02.png",
//    "logo_detail_page_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2017\/12\/11\/rosa-market-370x182-c.png",
//    "bns_description" : "<p>При каждой покупкой в сети супермаркетов &laquo;Rosa&raquo; вы &nbsp;получаете от 5 до 15% от ее стоимости в виде бонусов на вашу Гринкарту, которыми можно оплачивать &nbsp;товары и услуги у всех партнеров программы.<\/p>\r\n<p>Исключения:<\/p>\r\n<p>- Бонусы не начисляются и ими нельзя оплачивать покупку табачных изделий <em>(Закон РФ №15 от 23.02.2013)<em>&nbsp;В то ��е время, сумма, потраченная на табачные изделия учитывается при изменении статуса карты.<\/em><\/em><\/p>\r\n<p>- Бонусы не начисляются, но ими можно оплачивать покупку ЖНВЛС и детского питания.<\/p>\r\n<p>- Не допускается полная оплата бонусами алкогольной продукции, для которой&nbsp;&nbsp;в преду��мотренном законом порядке установлена минимальная розничная цена.&nbsp; Участник вправе оплатить бонусами ту часть цены алкогольной продук��ии, которая превышает&nbsp; минимальную розничную цену для данного вида алкогольной продукции, остальная часть цены товара (в размере не менее&nbsp;минимальной розничной цены для данного вида алкогольной продукции) должна быть оплачена денежными средствами.<\/p>",
//    "logo_shares_black_bg_src" : "http:\/\/api.green-bonus.ru\/data\/partners\/2017\/12\/11\/rosa-market-315x160-b.png"
//}

struct PartnerDetailsResponse {

    let description: String?
    let photos: [String]?
    let descriptionVideoSrc: String?
    let advantages: String?
    let benefits: String?
    let bonuses: [PartnerDetailsBonus]?
    let logoMapSrc: String?

    init(data: Data) {
        let json = JSON(data: data)
//        log("\(json)")

        description = json["description"].string

        if let photosArray = json["photos"].array {
            photos = photosArray.flatMap({ $0.string })
        } else {
            photos = nil
        }

        descriptionVideoSrc = json["video_code"].string
        advantages = json["features"].string
        benefits = json["bns_description"].string
        logoMapSrc = json["logo_map_src"].string

        if let array = json["bns_percents"].array {
            bonuses = array.map({ PartnerDetailsBonus(json: $0) })
        } else {
            bonuses = nil
        }
    }

}

struct PartnerDetailsBonus {

    let status: String?
    let percents: Int?

    init(json: JSON) {
        status = json["status"].string
        percents = json["percents"].int
    }

}
