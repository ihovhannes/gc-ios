//
//  SplashViewModel.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 31.07.17.
//  Copyright © 2017 Appril. All rights reserved.
//

import RxSwift
import RxCocoa

typealias SplashViewControllerBindings = (
    Observable<Void>
)

typealias SplashViewControllerBindingsFactory = () -> SplashViewControllerBindings

class SplashViewModel: ReactiveCompatible, DisposeBagProvider {
    
    fileprivate let bindingsFactory: SplashViewControllerBindingsFactory
    
    fileprivate(set) lazy var routingObservable = Observable<Routing>.never()
    
    required init(bindingsFactory: @escaping SplashViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory
        
        routingObservable = rx.observableRouting(bindingsFactory())
    }
    
    deinit {
        debugPrint("deinit \(#file)+\(#line)")
    }
}

fileprivate extension Reactive where Base == SplashViewModel {
    
    func observableRouting(_ didFinishLoadingObservable: Observable<Void>) -> Observable<Routing> {
        return didFinishLoadingObservable
            .flatMapLatest({ (_) -> Observable<String?> in
                return TokenService.instance.tokenObservable()
            })
            .map({ token in token != nil && token!.isNotEmpty })
            .map({ isLoggedIn in Routing.preparedRoot(isLoggedIn: isLoggedIn) })
    }
}
