//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift


class RegistrationPasswordViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate(set) lazy var acceptTrigger = PublishSubject<String>()
    fileprivate(set) lazy var changePasswordTrigger = PublishSubject<String>()

    fileprivate(set) lazy var routingObservable = PublishSubject<Routing>()

    var password: String = ""

    required init() {

        // -- Network accept

        let sendOfertaObservable = rx_sendOfertaAcceptObservable(acceptObservable: acceptTrigger.asObservable())
        let sendChangPassword = rx_sendChangePassword(changePasswordObservable: changePasswordTrigger.asObservable())

        sendOfertaObservable
                .subscribe(onNext: { [weak self] event in
                    var routing = Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil)

                    switch event {
                    case .next(let response):
                        if response.isSuccess {
                            self?.changePasswordTrigger.onNext(self?.password ?? "")
                            return
                        } else if let errorOpt = response.errors?.first, let error = errorOpt {
                            routing = Routing.alertView(title: "Ошибка.", body: error, repeatCallback: nil)
                        }
                    case .error(let error):
                        if let greenError = error as? GreencardError {
                            switch greenError {
                            case .inResponse(let msg):
                                routing = Routing.alertView(title: "Ошибка авторизации.", body: msg, repeatCallback: nil)
                            case .network:
                                routing = Routing.alertView(title: "Ошибка интернет-соединения.", body: "Возможно, вы не подключены к интернету либо сигнал очень слабый.", repeatCallback: nil)
                            case .unauthorized, .unknown:
                                routing = Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil)

                            }
                        }
                    case .completed:
                        log("Filtered case")
                    }

                    self?.routingObservable.onNext(routing)
                })
                .disposed(by: disposeBag)

        sendChangPassword
                .subscribe(onNext: { [weak self] event in
                    var routing = Routing.alertView(title: "Неизвестная ошбика", body: nil, repeatCallback: nil)

                    switch event {
                    case .next(let response):
                        if response.isSuccess {
                            routing = Routing.dismissOfertaAndRefreshMain
                        } else if let errorOpt = response.errors?.first, let error = errorOpt {
                            routing = Routing.alertView(title: "Ошибка.", body: error, repeatCallback: nil)
                        }
                    case .error(let error):
                        if let greenError = error as? GreencardError {
                            switch greenError {
                            case .inResponse(let msg):
                                routing = Routing.alertView(title: "Ошибка авторизации.", body: msg, repeatCallback: nil)
                            case .network:
                                routing = Routing.alertView(title: "Ошибка интернет-соединения.", body: "Возможно, вы не подключены к интернету либо сигнал очень слабый.", repeatCallback: nil)
                            case .unauthorized, .unknown:
                                routing = Routing.alertView(title: "Неизвестная ошбика.", body: nil, repeatCallback: nil)

                            }
                        }
                    case .completed:
                        log("Filtered case")
                    }

                    self?.routingObservable.onNext(routing)
                })
                .disposed(by: disposeBag)
    }

    deinit {
        log("deinit")
    }


}

extension RegistrationPasswordViewModel {

    // -- Network accept oferta

    func rx_sendOfertaAcceptObservable(acceptObservable: Observable<String>) -> Observable<Event<UserActivateResponse>> {
        return acceptObservable
                .do(onNext: { _ in LoadingIndicator.show() })
                .do(onNext: { [weak self] password in
                    self?.password = password
                })
                .flatMapLatest { _ -> Observable<String> in
                    return TokenService.instance.tokenOrErrorObservable()
                }
                .flatMapLatest { token -> Observable<Event<UserActivateResponse>> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<Event<UserActivateResponse>> in
                        let request: Request<UserActivateStrategy> = service.request()
                        return request.observe(()).materialize()
                    })
                }
                .filter({ event in !event.isCompleted })
                .observeOn(MainScheduler.instance)
                .do(onNext: { event in
                    if event.error != nil {
                        LoadingIndicator.hide()
                    }
                }, onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    // -- Network Change Password

    func rx_sendChangePassword(changePasswordObservable: Observable<String>) -> Observable<Event<ChangePasswordResponse>> {
        return changePasswordObservable
                .flatMapLatest { arg -> Observable<(password: String, token: String)> in
                    return TokenService.instance.tokenOrErrorObservable()
                            .map {
                                (password: arg, token: $0)
                            }
                }
                .flatMapLatest { arg -> Observable<Event<ChangePasswordResponse>> in
                    return Observable.using({ NetworkService(token: arg.token) }, observableFactory: { service -> Observable<Event<ChangePasswordResponse>> in
                        let request: Request<ChangePasswordStrategy> = service.request()
                        return request.observe(arg.password).materialize()
                    })
                }
                .filter({ event in !event.isCompleted })
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() }, onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }


}
