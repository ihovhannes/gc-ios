//
//  AuthStrategy.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 26.10.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import Moya
import RxSwift

class AuthStrategy: NetworkStrategy {
    
    static func api(_ object: (String, String)) -> Api {
        return Api.login(phone: object.0, password: object.1)
    }
    
    static func error(_ error: MoyaError?) -> Observable<AuthResponse> {
        guard let error = error else { return Observable.error(GreencardError.unknown)}
        
        return Observable.error(error)
    }
    
    static func map(_ data: Data, object: (String, String)?) -> AuthResponse {
        return AuthResponse(data: data)
    }
    
    typealias StrategyObject = (String, String)
    
    typealias StrategyResult = AuthResponse
}
