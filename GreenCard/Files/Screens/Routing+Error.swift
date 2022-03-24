//
// Created by Hovhannes Sukiasian on 18/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation

protocol RoutingError {}

extension RoutingError {

    func errorToRouting(error: Error) -> Routing {
        if let greenError = error as? GreencardError {
            switch greenError {
            case .inResponse(let msg):
                return Routing.alertView(title: "Ошибка.", body: msg, repeatCallback: nil)
            case .network:
                return Routing.alertView(title: "Ошибка интернет-соединения.", body: "Возможно, вы не подключены к интернету либо сигнал очень слабый.", repeatCallback: nil)
            case .unauthorized, .unknown:
                return Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil)

            }
        }
        return Routing.alertView(title: "Неизвестная ошбика.", body: "\(error)", repeatCallback: nil)
    }



}

class ErrorHander {

    static func errorToRouting1(error: Error, repeatCallback: (() -> ())? ) -> Routing {
        if let greenError = error as? GreencardError {
            switch greenError {
            case .inResponse(let msg):
                return Routing.alertView(title: "Ошибка.", body: msg, repeatCallback: repeatCallback)
            case .network:
                return Routing.alertView(title: "Ошибка интернет-соединения.", body: "Возможно, вы не подключены к интернету либо сигнал очень слабый.", repeatCallback: repeatCallback)
            case .unauthorized, .unknown:
                return Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: repeatCallback)

            }
        }
        return Routing.alertView(title: "Неизвестная ошбика.", body: "\(error)", repeatCallback: repeatCallback)
    }

}
