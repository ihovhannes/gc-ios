//
// Created by Hovhannes Sukiasian on 25/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class RestorePasswordPhoneStrategy: NetworkStrategy {

    static func api(_ object: String) -> Api {
        return Api.restorePasswordPhone(phone: object)
    }

    static func error(_ error: MoyaError?) -> Observable<RestorePasswordPhoneResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: String? ) -> RestorePasswordPhoneResponse {
        return RestorePasswordPhoneResponse(data: data)
    }

    typealias StrategyObject = String
    typealias StrategyResult = RestorePasswordPhoneResponse

}
