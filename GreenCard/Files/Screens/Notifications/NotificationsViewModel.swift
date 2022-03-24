//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias NotificationsViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>
)

typealias NotificationsViewControllerBindingsFactory = () -> NotificationsViewControllerBindings

class NotificationsViewModel : ReactiveCompatible, DisposeBagProvider {

    fileprivate let bindingsFactory: NotificationsViewControllerBindingsFactory

    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()

    required init(bindingsFactory: @escaping NotificationsViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let menuRoutingObservable = rx.menuRouting(drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        routingObservable = rx.routingObservable(menuRoutingObservable)
    }

    deinit {
        log("deinit")
    }

}

fileprivate extension Reactive where Base == NotificationsViewModel {

    func menuRouting(drawerButtonObservable: Observable<Void>,
                     appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Routing> {
        return drawerButtonObservable
                .withLatestFrom(appearanceStateObservable)
                .filter { state in
                    state == .didAppear
                }
                .map { state in
                    Routing.switchMenu
                }
    }

    func routingObservable(_ observables: Observable<Routing>) -> Observable<Routing> {
        return Observable.merge(observables)
    }

}
