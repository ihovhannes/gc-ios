//
//  LoginViewModel.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 02.08.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import RxSwift
import RxCocoa
import Result

typealias LoginViewControllerBindings = (
        stub: Void,
        appearenceState: Observable<UIViewController.AppearanceState>?
)

typealias LoginViewControllerBindingsFactory = () -> LoginViewControllerBindings

class LoginViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate let bindingsFactory: LoginViewControllerBindingsFactory

    fileprivate(set) lazy var doLogin = PublishSubject<(String, String)>()

    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()

    required init(bindingsFactory: @escaping LoginViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let loginObservable = rx.loginObservable(didRequestLogin: doLogin.asObservable())
        let saveTokenObservable = rx.saveTokenObservable(didLogin: loginObservable)

        routingObservable = rx.routeToMainObservable(didFinishLogin: saveTokenObservable)
    }

    deinit {
        log("deinit")
    }
}

fileprivate extension Reactive where Base == LoginViewModel {

    func loginObservable(didRequestLogin: Observable<(String, String)>) -> Observable<Event<String>> {
        return didRequestLogin
                .do(onNext: { (_, _) in
                    LoadingIndicator.show()
                })
                .flatMapLatest({ (phone, password) -> Observable<Event<AuthResponse>> in
                    return Observable.using({ NetworkService(token: nil) }, observableFactory: { (service: NetworkService) -> Observable<Event<AuthResponse>> in
                        let request: Request<AuthStrategy> = service.request()
                        return request.observe((phone, password)).materialize()
                    })
                })
                .filter({ event in !event.isCompleted })
                .map({ (event: Event<AuthResponse>) -> Event<String> in
                    return event.map { response in
                        if let token = response.token {
                            return token
                        } else if let errorOpt = response.errors?.first, let error = errorOpt {
                            throw GreencardError.inResponse(msg: error)
                        }
                        throw GreencardError.unknown
                    }
                })

    }

    func saveTokenObservable(didLogin: Observable<Event<String>>) -> Observable<Event<Void>> {
        return didLogin
                .map { event in
                    event.map(TokenService.instance.saveToken)
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { (_) in
                    LoadingIndicator.hide()
                }, onError: { (_) in
                    LoadingIndicator.hide()
                })
                .shareReplayLatestWhileConnected()
    }

    func routeToMainObservable(didFinishLogin: Observable<Event<Void>>) -> Observable<Routing> {
        return didFinishLogin.map({ event in
            switch event {
            case .next:
                return Routing.loginSuccess
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
