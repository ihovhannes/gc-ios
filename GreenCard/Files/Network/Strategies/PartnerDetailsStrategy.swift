//
// Created by Hovhannes Sukiasian on 22/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class PartnerDetailsStrategy : NetworkStrategy {

    static func api(_ object: Int64) -> Api {
        return Api.partnerDetails(id: object)
    }

    static func error(_ error: MoyaError?) -> Observable<PartnerDetailsResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }
        return Observable.error(error)
    }

    static func map(_ data: Data, object: Int64?) -> PartnerDetailsResponse {
        return PartnerDetailsResponse(data: data)
    }

    typealias StrategyObject = Int64
    typealias StrategyResult = PartnerDetailsResponse

}
