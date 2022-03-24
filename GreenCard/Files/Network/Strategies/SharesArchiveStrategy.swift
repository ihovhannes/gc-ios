//
// Created by Hovhannes Sukiasian on 29/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Moya
import RxSwift

class SharesArchiveStrategy: NetworkStrategy {

    static func api(_ object: Int) -> Api {
        return Api.sharesArchive(page: object)
    }

    static func error(_ error: MoyaError?) -> Observable<OfferListResponse> {
        guard let error = error else { return Observable.error(GreencardError.unknown)}

        return Observable.error(error)
    }

    static func map(_ data: Data, object: Int?) -> OfferListResponse {
        return OfferListResponse(data: data)
    }

    typealias StrategyObject = Int
    typealias StrategyResult = OfferListResponse

}
