//
// Created by Hovhannes Sukiasian on 05/02/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//


import Moya
import RxSwift


class CardSmsForAppendStrategy : NetworkStrategy {

    static func api(_ object: String) -> Api {
        return Api.cardSmsToAppend(userId: object)
    }

    static func error(_ error: MoyaError?) -> Observable<AttachedCardResponse> {
        guard let error = error else { return Observable.error(GreencardError.unknown)}

        return Observable.error(error)
    }

    static func map(_ data: Data, object: String?) -> AttachedCardResponse {
        return AttachedCardResponse(data: data)
    }


    typealias StrategyObject = String
    typealias StrategyResult = AttachedCardResponse

}
