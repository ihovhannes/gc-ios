//
// Created by Hovhannes Sukiasian on 24/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift

class RestorePasswordSmsViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate(set) lazy var sendTrigger = PublishSubject<(phoneNumber: String, smsCode: String)>()

    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()

    var phoneNumber: String = ""
    var smsCode: String = ""

    required init() {
        let checkSmsObservable = rx_checkSms(smsObservable: sendTrigger.asObservable())
        routingObservable = rx_routeToChangPassword(didSendObservable: checkSmsObservable)
    }

    deinit {
        log("deinit")
    }

}

extension RestorePasswordSmsViewModel {

    func rx_checkSms(smsObservable: Observable<(phoneNumber: String, smsCode: String)>) -> Observable<Event<RestorePasswordSmsResponse>> {
        return smsObservable
                .do(onNext: { [unowned self] args in
                    self.phoneNumber = args.phoneNumber
                    self.smsCode = args.smsCode
                })
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMap { arg -> Observable<Event<RestorePasswordSmsResponse>> in
                    return Observable.using({NetworkService(token: nil)}, observableFactory: { service -> Observable<Event<RestorePasswordSmsResponse>> in
                        let request: Request<RestorePasswordSmsStrategy> = service.request()
                        return request.observe((phone: arg.phoneNumber, sms: arg.smsCode)).materialize()
                    })
                }
                .filter({ event in !event.isCompleted })
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() }, onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_routeToChangPassword(didSendObservable: Observable<Event<RestorePasswordSmsResponse>>) -> Observable<Routing> {
        return didSendObservable.map({ [weak self] event in
            switch event {
            case .next(let response):
                if response.isSuccess {
                    return Routing.restorePasswordConfirm(phone: self?.phoneNumber ?? "", smsCode: self?.smsCode ?? "")
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
