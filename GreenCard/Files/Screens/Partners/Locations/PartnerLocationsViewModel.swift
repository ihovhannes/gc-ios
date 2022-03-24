//
// Created by Hovhannes Sukiasian on 28/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


typealias PartnerLocationsViewControllerBindings = (
        appearanceState: Observable<UIViewController.AppearanceState>,
        drawerButton: Observable<Void>
)

typealias PartnerLocationsViewControllerBindingsFactory = () -> PartnerLocationsViewControllerBindings

class PartnerLocationsViewModel: ReactiveCompatible, DisposeBagProvider {

    lazy var partnerId: Variable<Int64?> = Variable(nil)
    lazy var partnerColor: Variable<UIColor?> = Variable(nil)
    lazy var partnerVendors: Variable<PartnerVendorsResponse?> = Variable(nil)
    lazy var partnerMapLogoSrc: Variable<String?> = Variable(nil)

    lazy var switcherData: Variable<[PartnerVendorItem]?> = Variable(nil)
    lazy var mapData: Variable<[PartnerLocationsMarkerData]?> = Variable(nil)

    fileprivate let bindingsFactory: PartnerLocationsViewControllerBindingsFactory

    fileprivate(set) var menuRoutingObservable = Observable<Routing>.never()
    // --

    fileprivate(set) var vendorsObservable = Observable<PartnerVendorsResponse>.never()
    fileprivate(set) var switcherDataObservable = Observable<[PartnerVendorItem]>.never()
    fileprivate(set) var mapDataObservable = Observable<[PartnerLocationsMarkerData]>.never()

    required init(bindingsFactory: @escaping PartnerLocationsViewControllerBindingsFactory) {
        self.bindingsFactory = bindingsFactory

//        let willAppearObservable = rx_willAppearObservableOnce(bindingsFactory().appearanceState)
//        let partnerIdObservable = partnerId.asObservable()

        let didAppearObservable = rx_didAppearObservableOnce(bindingsFactory().appearanceState)

        // -- Navigation

        menuRoutingObservable = rx_menuRouting(drawerButtonObservable: bindingsFactory().drawerButton,
                appearanceStateObservable: bindingsFactory().appearanceState)

        // -- Data source

        vendorsObservable = rx_vendorsObservable(didAppearObservable, vendorsObservable: partnerVendors.asObservable())

        vendorsObservable
                .bind(to: self.rx.vendorsObserver)
                .disposed(by: disposeBag)

        switcherDataObservable = switcherData
                .asObservable()
                .filter({ $0 != nil })
                .map({ $0! })

        mapDataObservable = mapData
                .asObservable()
                .filter({ $0 != nil })
                .map({ $0! })

    }

}


extension PartnerLocationsViewModel: RxViewModelAppearance, RxViewModelError {

}

extension PartnerLocationsViewModel {

    func rx_menuRouting(drawerButtonObservable: Observable<Void>,
                        appearanceStateObservable: Observable<UIViewController.AppearanceState>) -> Observable<Routing> {
        return drawerButtonObservable
                .withLatestFrom(appearanceStateObservable)
                .filter({ state in state == .didAppear })
                .map({ [weak self]   state in
                    Routing.backWithMenuColor(color: self?.partnerColor.value)
                })
    }

    func rx_vendorsObservable(_ didAppearObservable: Observable<Void>, vendorsObservable: Observable<PartnerVendorsResponse?>) -> Observable<PartnerVendorsResponse> {
        return didAppearObservable
                .flatMapLatest({ vendorsObservable })
                .filter({ $0 != nil })
                .map({ $0! })
    }

}

extension Reactive where Base == PartnerLocationsViewModel {

    var vendorsObserver: AnyObserver<PartnerVendorsResponse> {
        return Binder(base, binding: { (viewModel: PartnerLocationsViewModel, input: PartnerVendorsResponse) in
            if let vendors = input.list, let mapLogo = viewModel.partnerMapLogoSrc.value {
                let visibleVendors = vendors.filter({ $0.longitude != nil && $0.latitude != nil })
                let markerData = visibleVendors.map({ PartnerLocationsMarkerData(latitude: $0.latitude!, longitude: $0.longitude!, logoSrc: mapLogo) })

                viewModel.switcherData.value = visibleVendors
                viewModel.mapData.value = markerData
            } else {
                viewModel.switcherData.value = []
                viewModel.mapData.value = []
            }
        }).asObserver()
    }
}
