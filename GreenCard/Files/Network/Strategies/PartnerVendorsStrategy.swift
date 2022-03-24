//
// Created by Hovhannes Sukiasian on 28/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Moya
import RxSwift

class PartnerVendorsStrategy: NetworkStrategy {

    static func api(_ object: (Int64, Int?)) -> Api {
        return Api.partnerVendors(partnerId: object.0, page: object.1)
    }

    static func error(_ error: MoyaError?) -> Observable<PartnerVendorsResponse> {
        guard let error = error else {return Observable.error(GreencardError.unknown)}

        return Observable.error(error)
    }

    static func map(_ data: Data, object: (Int64, Int?)? ) -> PartnerVendorsResponse {
        return PartnerVendorsResponse(data: data)
    }

    typealias StrategyObject = (Int64, Int?)
    typealias StrategyResult = PartnerVendorsResponse

}
