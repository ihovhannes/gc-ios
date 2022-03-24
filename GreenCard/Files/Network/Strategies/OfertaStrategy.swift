//
// Created by Hovhannes Sukiasian on 14/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class OfertaStrategy: NetworkStrategy {

    static func api(_ object: ()) -> Api {
        return Api.oferta
    }

    static func error(_ error: MoyaError?) -> Observable<OfertaResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: ()?) -> OfertaResponse {
        return OfertaResponse(data: data)
    }

    typealias StrategyObject = ()
    typealias StrategyResult = OfertaResponse

}
