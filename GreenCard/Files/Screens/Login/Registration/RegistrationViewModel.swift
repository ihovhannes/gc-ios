//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift

class RegistrationViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate(set) lazy var checkCard = PublishSubject<(number: String, code: String)>()

    var number = ""
    var code = ""

    lazy var routingObservable = Observable<Routing>.never()

    required init() {
        let sendCheckCardObservable = rx_sendCheckCardObservable(checkCardObservable: checkCard.asObservable())

        routingObservable = rx_transformCheckCardObservable(sendCheckCardObservable: sendCheckCardObservable)
    }

}

fileprivate extension RegistrationViewModel {

    // -- Network

    func rx_sendCheckCardObservable(checkCardObservable: Observable<(number: String, code: String)>) -> Observable<CheckCardResponse> {
        return checkCardObservable
                .do(onNext: { _ in LoadingIndicator.show() })
                .do(onNext: { [weak self] args in
                    self?.number = args.0
                    self?.code = args.1
                })
                .flatMapLatest { (arg: (number: String, code: String)) -> Observable<CheckCardResponse> in
                    return Observable.using({ NetworkService(token: nil) }, observableFactory: { service -> Observable<CheckCardResponse> in
                        let request: Request<CheckCardStrategy> = service.request()
                        return request.observe((number: arg.number, code: arg.code))
                    })
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_transformCheckCardObservable(sendCheckCardObservable: Observable<CheckCardResponse>) -> Observable<Routing> {
        return sendCheckCardObservable
                .map { [weak self] response -> Routing in
                    if let errors = response.errors {
                        if let error = errors.first {
                            return Routing.alertView(title: "Ошибка.", body: error, repeatCallback: nil)
                        }
                        return Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil)
                    }
                    if let isValid = response.isValid, isValid, let isRegistered = response.isRegistered, !isRegistered {
                        return Routing.registrationDetails(cardNumber: self?.number ?? "", cardCode: self?.code ?? "")
                    }
                    return Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil)
                }
                .catchError({ error -> Observable<Routing> in
                    if let greenError = error as? GreencardError {
                        switch greenError {
                        case .inResponse(let msg):
                            return Observable.just(Routing.alertView(title: "Ошибка авторизации.", body: msg, repeatCallback: nil))
                        case .network:
                            return Observable.just(Routing.alertView(title: "Ошибка интернет-соединения.", body: "Возможно, вы не подключены к интернету либо сигнал очень слабый.", repeatCallback: nil))
                        case .unauthorized, .unknown:
                            return Observable.just(Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil))

                        }
                    }
                    return Observable.just(Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil))
                })
    }

}
