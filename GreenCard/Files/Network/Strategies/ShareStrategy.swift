//
// Created by Hovhannes Sukiasian on 04/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Moya
import RxSwift

class ShareStrategy: NetworkStrategy {

    static func api(_ object: (shareId: Int64, isArchive: Bool)) -> Api {
        return object.isArchive ? Api.sharesArchiveDetail(id: object.shareId) : Api.share(id: object.shareId)
    }

    static func error(_ error: MoyaError?) -> Observable<ShareResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: (shareId: Int64, isArchive: Bool)?) -> ShareResponse {
        return ShareResponse(data: data)
    }

    typealias StrategyObject = (shareId: Int64, isArchive: Bool)
    typealias StrategyResult = ShareResponse

}
