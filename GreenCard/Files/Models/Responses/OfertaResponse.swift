//
// Created by Hovhannes Sukiasian on 14/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

/*
{
  "content" : "Много букв",
  "title" : "Оферта",
  "subheader" : "Договор участия в программе лояльности"
}
*/

struct OfertaResponse {

    let title: String
    let subTitle: String
    let content: String

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")

        title = json["title"].string ?? "Оферта"
        subTitle = json["subheader"].string ?? "Договор участия в программе лояльности"

        content = json["content"].string ?? "Ошибка"

    }

}
