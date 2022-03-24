//
// Created by Hovhannes Sukiasian on 24/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

protocol RxViewModelNavigation {
}

extension RxViewModelNavigation {

    func rx_menuRouting(routing: Routing, drawerButtonObservable: Observable<Void>,
                        appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Routing> {
        return drawerButtonObservable
                .withLatestFrom(appearanceStateObservable)
                .filter({ state in state == .didAppear })
                .map({ state in routing })
    }

}

protocol RxViewModelAppearance {
}

extension RxViewModelAppearance {

    func rx_willAppearObservableOnce(_ appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Void> {
        return appearanceStateObservable
                .filter({ $0 == .willAppear })
                .map({ _ in () })
                .take(1)
                .share(replay: 1, scope: SubjectLifetimeScope.forever)
    }

    func rx_didAppearObservableOnce(_ appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Void> {
        return appearanceStateObservable
                .filter({ $0 == .didAppear })
                .map({ _ in () })
                .take(1)
                .share(replay: 1, scope: SubjectLifetimeScope.forever)
    }

}

protocol RxViewModelUpdateable {
}

extension RxViewModelUpdateable {

    func rx_safeUpdateableObservable(observable: Observable<UpdateableObject>) -> Observable<UpdateableObject> {
        return observable
                .catchError { (error) -> Observable<UpdateableObject> in
            Observable.just(UpdateableObject(updates: .empty, animated: false))
        }
    }

    func rx_errorObservable(observable: Observable<UpdateableObject>) -> Observable<Void> {
        return observable.map({ _ in () })
    }

}

protocol RxViewModelError {

}

extension RxViewModelError {

    func rx_errorObservable<T>(observable: Observable<T>) -> Observable<Void> {
        return observable.map({ _ in ()})
    }
}
