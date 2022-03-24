//
// Created by Hovhannes Sukiasian on 16/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class UserActivateStrategy: NetworkStrategy {

    static func api(_ object: ()) -> Api{
        return Api.userActivate
    }

    static func error(_ error: MoyaError?) -> Observable<UserActivateResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: ()?) -> UserActivateResponse {
        return UserActivateResponse(data: data)
    }

    typealias StrategyObject = ()
    typealias StrategyResult = UserActivateResponse

}
