//
// Created by Hovhannes Sukiasian on 24/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift


class RestorePasswordConfirmViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate(set) lazy var sendTrigger = PublishSubject<(phoneNumber: String, smsCode: String, password: String)>()

    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()

    required init() {
        let changePasswordObservable = rx_changePassword(passwordObservable: sendTrigger.asObservable())
        routingObservable = rx_routeToAuthorize(didSendObservable: changePasswordObservable)
    }

    deinit {
        log("deinit")
    }

}

fileprivate extension RestorePasswordConfirmViewModel {

    func rx_changePassword(passwordObservable: Observable<(phoneNumber: String, smsCode: String, password: String)>) -> Observable<Event<RestorePasswordChangeResponse>> {
        return passwordObservable
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMap { arg -> Observable<Event<RestorePasswordChangeResponse>> in
                    return Observable.using({ NetworkService(token: nil) }, observableFactory: { service -> Observable<Event<RestorePasswordChangeResponse>> in
                        let request: Request<RestorePasswordChangeStrategy> = service.request()
                        return request.observe((phone: arg.phoneNumber, sms: arg.smsCode, password: arg.password)).materialize()
                    })
                }
                .filter({ event in !event.isCompleted })
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() }, onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_routeToAuthorize(didSendObservable: Observable<Event<RestorePasswordChangeResponse>>) -> Observable<Routing> {
        return didSendObservable.map({ event in
            switch event {
            case .next(let response):
                if response.isSuccess {
                    return Routing.restorePasswordDone
                } else if let errorOpt = response.errors?.first, let error = errorOpt {
                    return Routing.alertView(title: "Ошибка.", body: error, repeatCallback: nil)
                }
            case .error(let error):
                if let greenError = error as? GreencardError {
                    switch greenError {
                    case .inResponse(let msg):
                        return Routing.alertView(title: "Ошибка авторизации.", body: msg, repeatCallback: nil)
                    case .network:
                        return Routing.alertView(title: "Ошибка интернет-соединения.", body: "Возможно, вы не подключены к интернету либо сигнал очень слабый.", repeatCallback: nil)
                    case .unauthorized, .unknown:
                        return Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil)

                    }
                }
            case .completed:
                log("Filtered case")
            }
            return Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil)

        })
    }

}
