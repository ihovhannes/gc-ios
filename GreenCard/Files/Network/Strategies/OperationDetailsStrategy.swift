//
// Created by Hovhannes Sukiasian on 08/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class OperationDetailsStrategy: NetworkStrategy {

    static func api(_ object: String) -> Api {
        return Api.operationDetails(id: object)
    }

    static func error(_ error: MoyaError?) -> Observable<OperationDetailsResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }
        return Observable.error(error)
    }

    static func map(_ data: Data, object: String?) -> OperationDetailsResponse {
        return OperationDetailsResponse(data: data)
    }

    typealias StrategyObject = String
    typealias StrategyResult = OperationDetailsResponse

}
