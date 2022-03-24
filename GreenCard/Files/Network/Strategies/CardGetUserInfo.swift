//
// Created by Hovhannes Sukiasian on 05/02/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Moya
import RxSwift

class CardGetUserInfoStrategy: NetworkStrategy {

    static func api(_ object: (cardNumber: String, cardCode: String)) -> Api {
        return Api.cardGetUserInfo(cardNumber: object.cardNumber, cardCode: object.cardCode)
    }

    static func error(_ error: MoyaError?) -> Observable<UserResponse> {
        guard let error = error else { return Observable.error(GreencardError.unknown)}

        return Observable.error(error)
    }
    
    static func map(_ data: Data, object: (cardNumber: String, cardCode: String)? ) -> UserResponse {
        return UserResponse(data: data)
    }

    typealias StrategyObject = (cardNumber: String, cardCode: String)
    typealias StrategyResult = UserResponse

}
