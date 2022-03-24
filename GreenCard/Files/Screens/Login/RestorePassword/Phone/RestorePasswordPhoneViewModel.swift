//
// Created by Hovhannes Sukiasian on 24/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift

class RestorePasswordPhoneViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate(set) lazy var sendTrigger = PublishSubject<String>()

    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()

    var phoneNumber: String = ""

    required init() {
        let sendPhoneObservable = rx_sendPhone(phoneObservable: sendTrigger.asObservable())
        routingObservable = rx_routeToCheckSms(didSendObservable: sendPhoneObservable)
    }

    deinit {
        log("deinit")
    }

}

extension RestorePasswordPhoneViewModel {

    func rx_sendPhone(phoneObservable: Observable<String>) -> Observable<Event<RestorePasswordPhoneResponse>> {
        return phoneObservable
                .do(onNext: { [unowned self] arg in self.phoneNumber = arg })
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMap { arg -> Observable<Event<RestorePasswordPhoneResponse>> in
                    return Observable.using({ NetworkService(token: nil) }, observableFactory: { service -> Observable<Event<RestorePasswordPhoneResponse>> in
                        let request: Request<RestorePasswordPhoneStrategy> = service.request()
                        return request.observe(arg).materialize()
                    })
                }
                .filter({ event in !event.isCompleted })
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() }, onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_routeToCheckSms(didSendObservable: Observable<Event<RestorePasswordPhoneResponse>>) -> Observable<Routing> {
        return didSendObservable.map({ [weak self]  event in
            switch event {
            case .next(let response):
                if response.isSuccess {
                    return Routing.restorePasswordSms(phone: self?.phoneNumber ?? "")
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
