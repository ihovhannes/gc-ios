//
// Created by Hovhannes Sukiasian on 13/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias AboutViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>
)

typealias AboutViewControllerBindingsFactory = () -> AboutViewControllerBindings

class AboutViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate let bindingsFactory: AboutViewControllerBindingsFactory

    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()

    required init(bindingsFactory: @escaping AboutViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let menuRoutingObservable = rx.menuRouting(drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        routingObservable = rx.routingObservable(menuRoutingObservable)
    }

    deinit {
        log("deinit")
    }

}

fileprivate extension Reactive where Base == AboutViewModel {

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
