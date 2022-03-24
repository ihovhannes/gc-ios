//
//  UserStrategy.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 31.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Moya
import RxSwift

class UserStrategy: NetworkStrategy {
    
    static func api(_ object: UserStrategy.StrategyObject) -> Api {
        return Api.user
    }
    
    static func error(_ error: MoyaError?) -> Observable<UserResponse> {
        guard let error = error else { return Observable.error(GreencardError.unknown)}
        
        return Observable.error(error)
    }
    
    static func map(_ data: Data, object: UserStrategy.StrategyObject?) -> UserResponse {
        return UserResponse(data: data)
    }
    
    typealias StrategyObject = Void
    
    typealias StrategyResult = UserResponse
}
