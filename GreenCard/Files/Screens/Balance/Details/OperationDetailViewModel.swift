//
// Created by Hovhannes Sukiasian on 08/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias OperationDetailViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>
)

typealias OperationDetailViewControllerBindingsFactory = () -> OperationDetailViewControllerBindings

class OperationDetailViewModel: ReactiveCompatible, DisposeBagProvider {

    lazy var operationId: Variable<String?> = Variable(nil)

    fileprivate let bindingsFactory: OperationDetailViewControllerBindingsFactory

    fileprivate(set) var menuRoutingObservable = Observable<Routing>.never()
    fileprivate(set) var errorObservable = Observable<Void>.never()

    fileprivate(set) var updateOperationObservable = Observable<OperationDetailsResponse>.never()

    required init(bindingsFactory: @escaping OperationDetailViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let willAppearObservable = rx_willAppearObservableOnce(bindingsFactory().appearanceState)

        // -- Navigation
        menuRoutingObservable = rx_menuRouting(routing: Routing.switchMenu, drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        // -- Network
        let operationIdObservable = operationId.asObservable()
        let loadOperation = rx_loadOperationObservable(willAppearObservable, operationIdObservable: operationIdObservable)
        let saveOperation = rx_saveOperationObservable(loadOperationObservable: loadOperation)
        saveOperation
                .subscribe { input in
                    log("Saved operation \(input)")
                }
                .disposed(by: disposeBag)

        updateOperationObservable = rx_transform(loadOperationObservable: loadOperation)

        // -- Error

        errorObservable = rx_errorObservable(observable: updateOperationObservable)
    }

}

extension OperationDetailViewModel: RxViewModelNavigation, RxViewModelAppearance, RxViewModelError {
}

fileprivate extension OperationDetailViewModel {

    func rx_loadOperationObservable(_ willAppearObservable: Observable<Void>, operationIdObservable: Observable<String?>) -> Observable<OperationDetailsResponse> {
        return willAppearObservable
                .flatMapLatest({ operationIdObservable })
                .filter({ $0 != nil })
                .map({ $0! })
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest { (operationId: String) -> Observable<(operationId: String, token: String)> in
                    return TokenService.instance.tokenOrErrorObservable()
                            .map {
                                (operationId: operationId, token: $0)
                            }
                }
                .flatMapLatest { (operationId: String, token: String) -> Observable<OperationDetailsResponse> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<OperationDetailsResponse> in
                        let request: Request<OperationDetailsStrategy> = service.request()
                        return request.observe(operationId)
                    })
                }
                .do(onNext: nil, onError: { (error) in
                    log("\(error)")
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_transform(loadOperationObservable: Observable<OperationDetailsResponse>) -> Observable<OperationDetailsResponse> {
        return loadOperationObservable
                .map({ $0 }) // nothing to map
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_saveOperationObservable(loadOperationObservable: Observable<OperationDetailsResponse>) -> Observable<Void> {
        return Observable.just(())
    }

}
