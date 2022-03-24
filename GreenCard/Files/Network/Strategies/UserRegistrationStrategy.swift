//
// Created by Hovhannes Sukiasian on 15/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import Moya
import RxSwift

class UserRegistrationStrategy: NetworkStrategy {

    static func api(_ object: (cardNumber: String, cardCode: String, firstName: String, gender: String, birthDate: String, phone: String, email: String, agreement: Bool)) -> Api {
        return Api.userRegistration(
                cardNumber: object.cardNumber,
                cardCode: object.cardCode,
                firstName: object.firstName,
                gender: object.gender,
                birthDate: object.birthDate,
                phone: object.phone,
                email: object.email,
                agreement: object.agreement)
    }

    static func error(_ error: MoyaError?) -> Observable<StrategyResult> {
        guard let error = error else {
            return Observable.error(GreencardError.unknown)
        }

        return Observable.error(error)
    }

    static func map(_ data: Data, object: StrategyObject?) -> UserRegistrationResponse {
        return UserRegistrationResponse(data: data)
    }

    typealias StrategyObject = (cardNumber: String, cardCode: String, firstName: String, gender: String, birthDate: String, phone: String, email: String, agreement: Bool)
    typealias StrategyResult = UserRegistrationResponse

}

