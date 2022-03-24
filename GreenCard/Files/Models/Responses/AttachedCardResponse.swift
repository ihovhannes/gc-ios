//
// Created by Hovhannes Sukiasian on 05/02/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import SwiftyJSON

/*

    @Nullable
    @SerializedName("is_attached")
    private Boolean isAttached;

    @Nullable
    @SerializedName("sms_sent_to")
    private String smsSentTo;

    @Nullable
    @SerializedName("non_field_errors")
    private String errorMessage;

*/

struct AttachedCardResponse {

    let isAttached: Bool?
    let smsSentTo: String?
    var errors: [String?]?

    init(data: Data) {
        let json = JSON(data: data)
        log("\(json)")

        isAttached = json["is_attached"].bool
        smsSentTo = json["sms_sent_to"].string

        if let errorsJson = json["non_field_errors"].array {
            errors = errorsJson.map({ $0.string })
        }
    }

}
