//
// Created by Hovhannes Sukiasian on 15/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class CheckCardStrategy: NetworkStrategy {

    static func api(_ object: (number: String, code: String)) -> Api {
        return Api.checkCard(number: object.number, code: object.code)
    }

    static func error(_ error: MoyaError?) -> Observable<CheckCardResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: (number: String, code: String)?) -> CheckCardResponse {
        return CheckCardResponse(data: data)
    }

    typealias StrategyObject = (number: String, code: String)
    typealias StrategyResult = CheckCardResponse

}
