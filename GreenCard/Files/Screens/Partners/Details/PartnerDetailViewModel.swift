//
// Created by Hovhannes Sukiasian on 30/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

typealias PartnerDetailViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>,
        sharesButton: Observable<Void>
)

typealias PartnerDetailViewControllerBindingsFactory = () -> PartnerDetailViewControllerBindings


class PartnerDetailViewModel: ReactiveCompatible, DisposeBagProvider {

    lazy var partnerId: Variable<Int64?> = Variable(nil)
    lazy var partnerColor: Variable<UIColor> = Variable(UIColor.black)
    lazy var partnerLogoSrc: Variable<String?> = Variable(nil)
    lazy var partnerLogoMapSrc: Variable<String?> = Variable(nil)
    lazy var partnerVendors: Variable<PartnerVendorsResponse?> = Variable(nil)
    lazy var error = PublishSubject<Error>()

    fileprivate let bindingsFactory: PartnerDetailViewControllerBindingsFactory

    fileprivate(set) var menuRoutingObservable = Observable<Routing>.never()
    fileprivate(set) var sharesRoutingObservable = Observable<Routing>.never()
    fileprivate(set) var locationsRoutingObservable = Observable<Routing>.never()

    fileprivate(set) var errorObservable = Observable<Void>.never()

    fileprivate(set) lazy var updateDetailsObservable = Observable<PartnerDetailsResponse>.never()
    fileprivate(set) lazy var vendorsObservable = Observable<PartnerVendorsResponse>.never()

    required init(bindingsFactory: @escaping PartnerDetailViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

        let willAppearObservable = rx_willAppearObservableOnce(bindingsFactory().appearanceState)
        let partnerIdObservable = partnerId.asObservable()

        // -- Navigation

        menuRoutingObservable = rx_menuRouting(routing: Routing.switchMenu, drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        sharesRoutingObservable = rx_sharesRouting(tapObservable: bindingsFactory().sharesButton,
                partnerIdObservable: partnerIdObservable)

        locationsRoutingObservable = rx_locationsRouting(partnerIdObservable: partnerIdObservable)

        // -- Network
        let loadDetails = rx_loadDetailsObservable(willAppearObservable, partnerIdObservable: partnerIdObservable)
        let saveDetails = rx_saveDetailsObservable(loadDetailsObservable: loadDetails)
        saveDetails.subscribe { input in
                    log("Saved share \(input)")
                }
                .disposed(by: disposeBag)

        updateDetailsObservable = rx_transform(loadDetailsObservable: loadDetails)

        // -- Network

        let loadVendors = rx_loadVendorsObservable(willAppearObservable, partnerIdObservable: partnerIdObservable)
        let saveVendors = rx_saveVendorsObservable(loadVendorsObservable: loadVendors)

        saveVendors.subscribe { input in
                    log("Saved vendors \(input)")
                }
                .disposed(by: disposeBag)

        vendorsObservable = rx_transform(loadVendorsObservable: loadVendors)

        // -- Error

        errorObservable = rx_mergeErrorObservable(
                rx_errorObservable(observable: updateDetailsObservable),
                rx_errorObservable(observable: vendorsObservable)
        )

    }

}


extension PartnerDetailViewModel: RxViewModelNavigation, RxViewModelAppearance, RxViewModelError {
}

extension PartnerDetailViewModel {

    // -- Navigation

    func rx_sharesRouting(tapObservable: Observable<Void>, partnerIdObservable: Observable<Int64?>) -> Observable<Routing> {
        return tapObservable
                .flatMapLatest({ partnerIdObservable })
                .filter({ $0 != nil })
                .map({ $0! })
                .map { [unowned self] partnerId in
                    return Routing.partnerShares(partnerId: partnerId,
                            color: self.partnerColor.value,
                            logoSrc: self.partnerLogoSrc.value,
                            vendors: self.partnerVendors.value,
                            mapLogoSrc: self.partnerLogoMapSrc.value)
                }
    }

    func rx_locationsRouting(partnerIdObservable: Observable<Int64?>) -> Observable<Routing> {
        return Observable.just(())
                .flatMapLatest({ partnerIdObservable })
                .filter({ $0 != nil })
                .map({ $0! })
                .map { [unowned self] partnerId in
                    return Routing.partnerLocations(partnerId: partnerId,
                            color: self.partnerColor.value,
                            vendors: self.partnerVendors.value,
                            mapLogoSrc: self.partnerLogoMapSrc.value)
                }
    }

    // -- Network

    func rx_loadDetailsObservable(_ willAppearObservable: Observable<Void>, partnerIdObservable: Observable<Int64?>) -> Observable<PartnerDetailsResponse> {
        return willAppearObservable
                .flatMapLatest({ partnerIdObservable })
                .filter({ $0 != nil })
                .map({ $0! })
                .flatMapLatest { (partnerId: Int64) -> Observable<(partnerId: Int64, token: String)> in
                    return TokenService.instance.tokenOrErrorObservable()
                            .map {
                                (partnerId: partnerId, token: $0)
                            }
                }
                .flatMapLatest { (partnerId: Int64, token: String) -> Observable<Event<PartnerDetailsResponse>> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<Event<PartnerDetailsResponse>> in
                        let request: Request<PartnerDetailsStrategy> = service.request()
                        return request.observe(partnerId).materialize()
                    })
                }
                .do(onNext: { [unowned self] event in
                    if let error = event.error {
                        self.error.onNext(error)
                    }
                }, onError: { [unowned self] (error) in

                    log("\(error)")
                })
                .filter({ (event: Event<PartnerDetailsResponse>) in !event.isStopEvent && !event.isCompleted })
                .map({ event in event.element! })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_transform(loadDetailsObservable: Observable<PartnerDetailsResponse>) -> Observable<PartnerDetailsResponse> {
        return loadDetailsObservable
                .do(onNext: { [weak self] response in
                    self?.partnerLogoMapSrc.value = response.logoMapSrc
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
    }

    func rx_saveDetailsObservable(loadDetailsObservable: Observable<PartnerDetailsResponse>) -> Observable<Void> {
        return Observable.just(())
    }

    // -- Network

    func rx_loadVendorsObservable(_ willAppearObservable: Observable<Void>, partnerIdObservable: Observable<Int64?>) -> Observable<PartnerVendorsResponse> {
        return willAppearObservable
                .flatMapLatest({ partnerIdObservable })
                .filter({ $0 != nil })
                .map({ $0! })
                .flatMapLatest { (partnerId: Int64) -> Observable<(partnerId: Int64, token: String)> in
                    return TokenService.instance.tokenOrErrorObservable()
                            .map {
                                (partnerId: partnerId, token: $0)
                            }
                }
                .flatMapLatest { (partnerId: Int64, token: String) -> Observable<Event<PartnerVendorsResponse>> in
                    return Observable.using({ NetworkService(token: token) }, observableFactory: { service -> Observable<Event<PartnerVendorsResponse>> in
                        let request: Request<PartnerVendorsStrategy> = service.request()
                        return request.observe((partnerId, nil)).materialize()
                    })
                }
                .do(onNext: { [unowned self] event in
                    if let error = event.error {
                        self.error.onNext(error)
                    }
                }, onError: { [unowned self] (error) in
                    log("\(error)")
                })
                .filter({ (event: Event<PartnerVendorsResponse>) in !event.isStopEvent && !event.isCompleted })
                .map({ (event: Event<PartnerVendorsResponse>) in event.element! })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
    }

    func rx_transform(loadVendorsObservable: Observable<PartnerVendorsResponse>) -> Observable<PartnerVendorsResponse> {
        return loadVendorsObservable
                .do(onNext: { [weak self] response in
                    self?.partnerVendors.value = response
                })
                .share(replay: 1, scope: SubjectLifetimeScope.whileConnected)
                .observeOn(MainScheduler.instance)
    }

    func rx_saveVendorsObservable(loadVendorsObservable: Observable<PartnerVendorsResponse>) -> Observable<Void> {
        return Observable.just(())
    }

    // -- Error

    func rx_mergeErrorObservable(_ observables: Observable<Void>...) -> Observable<Void> {
        return Observable.merge(observables)
    }

}
