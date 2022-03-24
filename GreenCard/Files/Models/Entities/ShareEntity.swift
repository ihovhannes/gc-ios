//
//  OfferRealmModel.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 30.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import GRDB

class ShareEntity: Record {
    
    var id: Int64 = 0
    var partnerId: Int64 = 0
    var isSpecial: Bool = false
    var title: String?
    var startDate: Date?
    var endDate: Date?
    var horizontalImage: String?
    var verticalImage: String?
    var partnerLogo: String?
    var partnerLogoWhiteBg: String?
    var partnerLogoBlackBg: String?
    var partnerLogoMap: String?
    var partnerColor: String?
    var content: String?
    var updateDate: Date = Date()
    
    required init(row: Row) {
        super.init(row: row)
        id = row["id"]
        partnerId = row["partner_id"]
        isSpecial = row["is_special"]
        title = row["title"]
        startDate = row["start_date"]
        endDate = row["end_date"]
        horizontalImage = row["horizontal_image"]
        verticalImage = row["vertical_image"]
        partnerLogo = row["partner_logo"]
        partnerLogoWhiteBg = row["partner_logo_white_bg"]
        partnerLogoBlackBg = row["partner_logo_black_bg"]
        partnerLogoMap = row["partner_logo_map"]
        partnerColor = row["partner_color"]
        content = row["content"]
        updateDate = row["update_date"]
    }
    
    init(responseItem: ShareResponse) {
        super.init()
        id = responseItem.id ?? -1
        partnerId = responseItem.partnerId ?? 0
        isSpecial = responseItem.isSpecial ?? false
        title = responseItem.title ?? ""
        startDate = responseItem.startDate ?? Date(timeIntervalSince1970: 0.0)
        endDate = responseItem.endDate ?? Date(timeIntervalSince1970: 0.0)
        horizontalImage = responseItem.horizontalImage ?? ""
        verticalImage = responseItem.verticalImage ?? ""
        partnerLogo = responseItem.partnerLogo ?? ""
        partnerLogoWhiteBg = responseItem.partnerLogoWhiteBg ?? ""
        partnerLogoBlackBg = responseItem.partnerLogoBlackBg ?? ""
        partnerLogoMap = responseItem.partnerLogoMap ?? ""
        partnerColor = responseItem.partnerColor ?? ""
        content = responseItem.content ?? ""
    }
    
    override class var databaseTableName: String {
        return "share"
    }
    
    override func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["partner_id"] = partnerId
        container["is_special"] = isSpecial
        container["title"] = title
        container["start_date"] = startDate
        container["end_date"] = endDate
        container["horizontal_image"] = horizontalImage
        container["vertical_image"] = verticalImage
        container["partner_logo"] = partnerLogo
        container["partner_logo_white_bg"] = partnerLogoWhiteBg
        container["partner_logo_black_bg"] = partnerLogoBlackBg
        container["partner_logo_map"] = partnerLogoMap
        container["partner_color"] = partnerColor
        container["content"] = content
        container["update_date"] = updateDate
    }
}
