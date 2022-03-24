//
// Created by Hovhannes Sukiasian on 04/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ShareResponse {
    
    let id: Int64?
    let partnerId: Int64?
    let isSpecial: Bool?
    let title: String?
    let startDate: Date?
    let endDate: Date?
    let horizontalImage: String?
    let verticalImage: String?
    let partnerLogo: String?
    let partnerLogoWhiteBg: String?
    let partnerLogoBlackBg: String?
    let partnerLogoMap: String?
    let partnerColor: String?
    
    let content: String?
    
    init(json: JSON) {
//        log("\(json)")
        id = json["id"].int64
        partnerId = json["partner_id"].int64
        isSpecial = json["is_special"].bool
        title = json["title"].string
        if let start = json["date_start"].string {
            startDate = Date(timeIntervalSince1970: Double(start) ?? 0.0)
        } else {
            startDate = nil
        }
        if let end = json["date_end"].string {
            endDate = Date(timeIntervalSince1970: Double(end) ?? 0.0)
        } else {
            endDate = nil
        }
        horizontalImage = json["image_horizontal_src"].string
        verticalImage = json["image_vertical_src"].string
        partnerLogo = json["partner_logo_src"].string
        partnerLogoWhiteBg = json["partner_logo_white_bg_src"].string
        partnerLogoBlackBg = json["partner_logo_black_bg_src"].string
        partnerLogoMap = json["partner_logo_map_src"].string
        partnerColor = json["partner_color"].string
        
        content = json["content"].string
    }
    
    init(data: Data) {
        let json = JSON(data: data)
        self.init(json: json)
    }
}
