//
// Created by Hovhannes Sukiasian on 05/02/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Moya
import RxSwift

class CardAppendNewStrategy : NetworkStrategy {

    static func api(_ object: (userId: String, smsCode: String)) -> Api {
        return Api.cardAppendNew(userId: object.userId, smsCode: object.smsCode)
    }

    static func error(_ error: MoyaError?) -> Observable<AttachedCardResponse> {
        guard let error = error else { return Observable.error(GreencardError.unknown)}

        return Observable.error(error)
    }

    static func map(_ data: Data, object: (userId: String, smsCode: String)?) -> AttachedCardResponse {
        return AttachedCardResponse(data: data)
    }

    typealias StrategyObject = (userId: String, smsCode: String)
    typealias StrategyResult = AttachedCardResponse

}
