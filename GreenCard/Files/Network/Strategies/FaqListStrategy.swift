//
// Created by Hovhannes Sukiasian on 15/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Moya
import RxSwift

class FaqListStrategy : NetworkStrategy {

    static func api(_ object: FaqListStrategy.StrategyObject) -> Api {
        return Api.faqList
    }

    static func error(_ error: MoyaError?) -> Observable<FaqListResponse> {
        guard let error = error else { return Observable.error(GreencardError.unknown)}

        return Observable.error(error)
    }

    static func map(_ data: Data, object: UserStrategy.StrategyObject?) -> FaqListResponse {
        return FaqListResponse(data: data)
    }

    typealias StrategyObject = Void
    typealias StrategyResult = FaqListResponse

}
