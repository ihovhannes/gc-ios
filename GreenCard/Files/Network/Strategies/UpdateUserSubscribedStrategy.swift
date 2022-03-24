//
// Created by Hovhannes Sukiasian on 15/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Moya
import RxSwift

class UpdateUserSubscribedSStrategy: NetworkStrategy {

    static func api(_ object: (push: Bool, sms: Bool, email: Bool)) -> Api {
        return Api.updateUserSubscribed(push: object.push, sms: object.sms, email: object.email)
    }

    static func error(_ error: MoyaError?) -> Observable<UpdateUserSubscribedResponse> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: (push: Bool, sms: Bool, email: Bool)?) -> UpdateUserSubscribedResponse {
        return UpdateUserSubscribedResponse(data: data)
    }

    typealias StrategyObject = (push: Bool, sms: Bool, email: Bool)
    typealias StrategyResult = UpdateUserSubscribedResponse

}
