//
//  OfferListStrategy.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 30.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Moya
import RxSwift

class OfferListStrategy: NetworkStrategy {
    
    
    static func api(_ object: Int) -> Api {
        return Api.offerList(page: object)
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
