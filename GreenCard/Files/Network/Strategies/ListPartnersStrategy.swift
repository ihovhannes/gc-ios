//
// Created by Hovhannes Sukiasian on 24/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Moya
import RxSwift

class ListPartnersStrategy : NetworkStrategy {

    static func api(_ object: Int?) -> Api {
        return Api.partners(page: object)
    }

    static func error(_ error: MoyaError?) -> Observable<ListPartnersResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: Int??) -> ListPartnersResponse {
        return ListPartnersResponse(data: data)
    }


    typealias StrategyObject = Int?
    typealias StrategyResult = ListPartnersResponse

}
