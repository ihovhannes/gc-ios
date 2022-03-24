//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift


typealias SettingsViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>
)

typealias SettingsViewControllerBindingsFactory = () -> SettingsViewControllerBindings

class SettingsViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate let bindingsFactory: SettingsViewControllerBindingsFactory
    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()

    fileprivate(set) lazy var accountObservable = Observable<Event<Account>>.never()
    fileprivate(set) lazy var changePasswordObservable = Observable<ChangePasswordResponse>.never()

    fileprivate(set) lazy var errorObservable = Observable<Void>.never()

    fileprivate(set) lazy var toggleChecker = PublishSubject<(push: Bool, sms: Bool, email: Bool)>()
    fileprivate(set) lazy var changePassword = PublishSubject<String>()

    required init(bindingsFactory: @escaping SettingsViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let willAppearObservable = rx_willAppearObservableOnce(bindingsFactory().appearanceState)

        // -- Navigation

        let menuRoutingObservable = rx.menuRouting(drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        routingObservable = rx.routingObservable(menuRoutingObservable)

        // -- Network Account

        let loadAccountObservable = rx.loadAccountObservable(willAppearObservable: willAppearObservable)
        let saveAccountObservable = rx.saveAccountObservable(loadAccountObservable: loadAccountObservable)
        saveAccountObservable
                .subscribe { _ in
                    log("Saved user")
                }
                .disposed(by: disposeBag)

        accountObservable = rx.transformAccountObservable(loadAccountObservable: loadAccountObservable)

        // -- Network checker

        let sendChangeCheckerObservable = rx.sendChangeCheckerObservable(
                        checkerObservable: toggleChecker.asObservable())

        sendChangeCheckerObservable.subscribe { _ in
                    log("Checker sent")
                }
                .disposed(by: disposeBag)

        changePasswordObservable = rx.sendChangePassword(
                changePasswordObservable: changePassword.asObservable())

        // -- Error

        errorObservable = rx.errorObservable(rx_errorObservable(observable: accountObservable),
                rx_errorObservable(observable: sendChangeCheckerObservable),
                rx_errorObservable(observable: changePasswordObservable))
    }

}

extension SettingsViewModel: RxViewModelAppearance, RxViewModelError {

}

fileprivate extension Reactive where Base == SettingsViewModel {

    // -- Navigation

    func menuRouting(drawerButtonObservable: Observable<Void>,
                     appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Routing> {
        return drawerButtonObservable
                .withLatestFrom(appearanceStateObservable)
                .filter({ state in state == .didAppear })
                .map({ state in Routing.switchMenu })
    }

    func routingObservable(_ observables: Observable<Routing>) -> Observable<Routing> {
        return Observable.merge(observables)
    }

    // -- Network Account

    func loadAccountObservable(willAppearObservable: Observable<Void>) -> Observable<Event<UserResponse>> {
        return willAppearObservable
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest { _ -> Observable<String> in
                    return TokenService.instance.tokenOrErrorObservable()
                }
                .flatMapLatest { token -> Observable<Event<UserResponse>> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<Event<UserResponse>> in
                        let request: Request<UserStrategy> = service.request()
                        return request.observe(()).materialize()
                    })
                }
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func transformAccountObservable(loadAccountObservable: Observable<Event<UserResponse>>) -> Observable<Event<Account>> {
        return loadAccountObservable
                .map({ event in event.map(Account.init(apiObject:)) })
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func saveAccountObservable(loadAccountObservable: Observable<Event<UserResponse>>) -> Observable<Void> {
        return Observable.just(()) //TODO: rewrite for saving
    }

    // -- Network Checkers

    func sendChangeCheckerObservable(checkerObservable: Observable<(push: Bool, sms: Bool, email: Bool)>) -> Observable<UpdateUserSubscribedResponse> {
        return checkerObservable
                .flatMapLatest { arg -> Observable<(checkers: (push: Bool, sms: Bool, email: Bool), token: String)> in
                    return TokenService.instance.tokenOrErrorObservable()
                            .map {
                                (checkers: arg, token: $0)
                            }
                }
                .flatMapLatest { arg -> Observable<UpdateUserSubscribedResponse> in
                    return Observable.using({ NetworkService(token: arg.token) }, observableFactory: { service -> Observable<UpdateUserSubscribedResponse> in
                        let request: Request<UpdateUserSubscribedSStrategy> = service.request()
                        return request.observe(arg.checkers)
                    })
                }
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    // -- Network Change Password

    func sendChangePassword(changePasswordObservable: Observable<String>) -> Observable<ChangePasswordResponse> {
        return changePasswordObservable
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest { arg -> Observable<(password: String, token: String)> in
                    return TokenService.instance.tokenOrErrorObservable()
                            .map {
                                (password: arg, token: $0)
                            }
                }
                .flatMapLatest { arg -> Observable<ChangePasswordResponse> in
                    return Observable.using({ NetworkService(token: arg.token) }, observableFactory: { service -> Observable<ChangePasswordResponse> in
                        let request: Request<ChangePasswordStrategy> = service.request()
                        return request.observe(arg.password)
                    })
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    // -- Errors

    func errorObservable(_ observables: Observable<Void>...) -> Observable<Void> {
        return Observable.merge(observables)
    }

}
