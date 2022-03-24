//
// Created by Hovhannes Sukiasian on 15/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Moya
import RxSwift

class ChangePasswordStrategy: NetworkStrategy {


    static func api(_ object: String) -> Api{
        return Api.changePassword(password: object)
    }

    static func error(_ error: MoyaError?) -> Observable<ChangePasswordResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: String?) -> ChangePasswordResponse {
        return ChangePasswordResponse(data: data)
    }

    typealias StrategyObject = String
    typealias StrategyResult = ChangePasswordResponse

}
