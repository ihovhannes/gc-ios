//
// Created by Hovhannes Sukiasian on 06/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Moya
import RxSwift

class CardsListStrategy : NetworkStrategy {

    static func api(_ object: ()) -> Api {
        return Api.cardsList
    }

    static func error(_ error: MoyaError?) -> Observable<CardsListResponse> {
        guard let error = error else { return Observable.error(GreencardError.unknown)}

        return Observable.error(error)
    }

    static func map(_ data: Data, object: ()? ) -> CardsListResponse {
        return CardsListResponse(data: data)
    }

    typealias StrategyObject = Void
    typealias StrategyResult = CardsListResponse

}
