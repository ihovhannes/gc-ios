//
// Created by Hovhannes Sukiasian on 06/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Moya
import RxSwift

class CardChangeStateStrategy : NetworkStrategy {

    static func api(_ object: (cardId: Int64, password: String)) -> Api {
        return Api.cardChangeState(cardId: object.cardId, password: object.password)
    }

    static func error(_ error : MoyaError?) -> Observable<CardChangeStateResponse> {
        guard let error = error else { return Observable.error(GreencardError.unknown)}

        return Observable.error(error)
    }

    static func map( _ data: Data, object: (cardId: Int64, password: String)? ) -> CardChangeStateResponse {
        return CardChangeStateResponse(data: data)
    }

    typealias StrategyObject = (cardId: Int64, password: String)
    typealias StrategyResult = CardChangeStateResponse

}
