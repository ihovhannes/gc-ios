//
// Created by Hovhannes Sukiasian on 30/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Moya
import RxSwift

class SharesArchiveDetailStrategy : NetworkStrategy {

    static func api(_ object: Int64) -> Api {
        return Api.sharesArchiveDetail(id: object)
    }

    static func error(_ error: MoyaError?) -> Observable<ShareResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: Int64?) -> ShareResponse {
        return ShareResponse(data: data)
    }

    typealias StrategyObject = Int64
    typealias StrategyResult = ShareResponse

}
