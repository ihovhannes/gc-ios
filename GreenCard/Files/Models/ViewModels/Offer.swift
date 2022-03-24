//
//  OfferViewModel.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 30.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Foundation

struct Offer {
    
    static var formatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "до dd / MM / yy"
        return dateFormatter
    }

    let id: Int64
    let isSpecial: Bool
    let title: String
    let endDate: String
    let image: URL?
    let partnerImage: URL?
    let timeLeft: String

    init(apiObject: ShareResponse) {
        id = apiObject.id ?? -1
        isSpecial = apiObject.isSpecial ?? false
        title = apiObject.title ?? ""

        if let date = apiObject.endDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd / MM / yy"
            endDate = "до " + formatter.string(from: date)
            let diff = Int(date.timeIntervalSince(Date()) / 3600 / 24) + 1
            timeLeft = String(diff)
        } else {
            endDate = ""
            timeLeft = ""
        }
        image = URL(string: apiObject.horizontalImage ?? "")
//        partnerImage = URL(string: apiObject.partnerImage ?? "")
        partnerImage = apiObject.partnerLogoWhiteBg.flatMap({ URL(string: $0) })
    }

    init(shareEntity: ShareEntity) {
        id = shareEntity.id
        isSpecial = shareEntity.isSpecial
        title = shareEntity.title ?? ""
        
        if let shareEndDate = shareEntity.endDate {
            endDate = Offer.formatter.string(from: shareEndDate)
            let time = Int(shareEndDate.timeIntervalSince(Date()) / 3600 / 24) + 1
            timeLeft = String(time)
        } else {
            endDate = ""
            timeLeft = ""
        }
        
        if let shareImageUrl = shareEntity.horizontalImage {
            image = URL(string: shareImageUrl)
        } else {
            image = nil
        }
        if let partnerImageUrl = shareEntity.partnerLogoWhiteBg {
            partnerImage = URL(string: partnerImageUrl)
        } else {
            partnerImage = nil
        }
        
    }
}
