//
// Created by Hovhannes Sukiasian on 13/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift

typealias RegistrationOfertaViewControllerBindings = Observable<UIViewController.AppearanceState>

typealias RegistrationOfertaViewControllerBindingsFactory = () -> RegistrationOfertaViewControllerBindings

class RegistrationOfertaViewModel: ReactiveCompatible, DisposeBagProvider {

    fileprivate let bindingsFactory: RegistrationOfertaViewControllerBindingsFactory

    fileprivate(set) lazy var acceptTrigger = PublishSubject<()>()

    fileprivate(set) lazy var ofertaObservable = Observable<(title: String, subTitle: String, content: String)>.never()

    fileprivate(set) lazy var errorObservable = Observable<Void>.never()

    required init(bindingsFactory: @escaping RegistrationOfertaViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let willAppearObservable = rx_willAppearObservableOnce(bindingsFactory())

        // -- Network

        let loadOfertaObservable = rx_loadOfertaObservable(willAppearsObservable: willAppearObservable)
        let saveOfertaObservable = rx_saveOfertaObservable(loadOfertaObservable: loadOfertaObservable)
        saveOfertaObservable
                .subscribe { arg in
                    log("Saved oferta \(arg)")
                }
                .disposed(by: disposeBag)

        ofertaObservable = rx_transformOfertaObservable(loadOfertaObservable: loadOfertaObservable)


        // -- Error

        errorObservable = rx_errorObservable(observable: ofertaObservable)
    }

}

extension RegistrationOfertaViewModel: RxViewModelAppearance, RxViewModelError {
}

extension RegistrationOfertaViewModel {

    // -- Network

    func rx_loadOfertaObservable(willAppearsObservable: Observable<Void>) -> Observable<OfertaResponse> {
        return willAppearsObservable
                .do(onNext: { _ in LoadingIndicator.show() })
                .flatMapLatest { token -> Observable<OfertaResponse> in
                    return Observable.using({ NetworkService(token: nil) }, observableFactory: { service -> Observable<OfertaResponse> in
                        let request: Request<OfertaStrategy> = service.request()
                        return request.observe(())
                    })
                }
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_transformOfertaObservable(loadOfertaObservable: Observable<OfertaResponse>) -> Observable<(title: String, subTitle: String, content: String)> {
        return loadOfertaObservable
                .map({ response in (title: response.title, subTitle: response.subTitle, content: response.content) })
                .observeOn(MainScheduler.instance)
                .do(onNext: { _ in LoadingIndicator.hide() },
                        onError: { _ in LoadingIndicator.hide() })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_saveOfertaObservable(loadOfertaObservable: Observable<OfertaResponse>) -> Observable<Void> {
        return Observable.just(())
    }



}
