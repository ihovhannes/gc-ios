//
// Created by Hovhannes Sukiasian on 06/02/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class RestorePasswordSmsStrategy: NetworkStrategy {

    static func api(_ object: (phone: String, sms: String)) -> Api {
        return Api.restorePasswordSms(phone: object.phone, sms: object.sms)
    }

    static func error(_ error: MoyaError?) -> Observable<RestorePasswordSmsResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: (phone: String, sms: String)?) -> RestorePasswordSmsResponse {
        return RestorePasswordSmsResponse(data: data)
    }

    typealias StrategyObject = (phone: String, sms: String)
    typealias StrategyResult = RestorePasswordSmsResponse

}
