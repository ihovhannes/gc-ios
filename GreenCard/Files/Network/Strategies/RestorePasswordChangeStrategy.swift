//
// Created by Hovhannes Sukiasian on 06/02/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class RestorePasswordChangeStrategy : NetworkStrategy {

    static func api(_ object: (phone: String, sms: String, password: String)) -> Api {
        return Api.restorePasswordChange(phone: object.phone, sms: object.sms, password: object.password)
    }

    static func error(_ error: MoyaError?) -> Observable<RestorePasswordChangeResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object:  (phone: String, sms: String, password: String)?) -> RestorePasswordChangeResponse {
        return RestorePasswordChangeResponse(data: data)
    }

    typealias StrategyObject = (phone: String, sms: String, password: String)
    typealias StrategyResult = RestorePasswordChangeResponse

}
