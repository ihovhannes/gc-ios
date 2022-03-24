//
// Created by Hovhannes Sukiasian on 06/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class OperationsListStrategy: NetworkStrategy {

    static func api(_ object: Int?) -> Api {
        return Api.operations(page: object)
    }

    static func error(_ error: MoyaError?) -> Observable<OperationsListResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: Int??) -> OperationsListResponse {
        return OperationsListResponse(data: data)
    }

    typealias StrategyObject = Int?
    typealias StrategyResult = OperationsListResponse

}
