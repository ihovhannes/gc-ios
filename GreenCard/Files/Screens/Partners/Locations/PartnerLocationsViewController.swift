//
// Created by Hovhannes Sukiasian on 28/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import PINRemoteImage
import RxCocoa
import RxSwift
import RxGesture

class PartnerLocationsViewController: UIViewController, DisposeBagProvider {

    fileprivate var partnerLocationsView: PartnerLocationsView {
        return view as? PartnerLocationsView ?? PartnerLocationsView()
    }

    fileprivate var viewModel: PartnerLocationsViewModel!

    init() {
        super.init(nibName: nil, bundle: nil)

        view = PartnerLocationsView()
        type = .partnerLocations

        viewModel = PartnerLocationsViewModel(bindingsFactory: getBindingsFactory())

        // -- Navigation

        viewModel
                .menuRoutingObservable
                .bind(to: self.rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Selections

        partnerLocationsView.markerTapped
                .bind(to: self.rx.markerTappedObserver)
                .disposed(by: disposeBag)

        partnerLocationsView.switcherWidget
                .selectionTrigger
                .bind(to: self.rx.switcherSwipeObserver)
                .disposed(by: disposeBag)

        // -- Data source

        viewModel
                .switcherDataObservable
                .bind(to: self.rx.switcherDataObserver)
                .disposed(by: disposeBag)

        viewModel
                .mapDataObservable
                .bind(to: self.rx.mapDataObserver)
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(partnerId: Int64, pageColor: UIColor, vendors: PartnerVendorsResponse?, mapLogoSrc: String?) -> PartnerLocationsViewController {
        viewModel.partnerId.value = partnerId
        viewModel.partnerMapLogoSrc.value = mapLogoSrc
        viewModel.partnerVendors.value = vendors
        viewModel.partnerColor.value = pageColor
        partnerLocationsView.configureInit(pageColor: pageColor)
        return self
    }

}

fileprivate extension PartnerLocationsViewController {

    func getBindingsFactory() -> PartnerLocationsViewControllerBindingsFactory {
        return { [unowned self] () -> PartnerLocationsViewControllerBindings in
            return PartnerLocationsViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable()
            )
        }
    }

}

extension Reactive where Base == PartnerLocationsViewController {

    var markerTappedObserver: AnyObserver<Int> {
        return Binder(base, binding: { (controller: PartnerLocationsViewController, input: Int) in
            if controller.partnerLocationsView.switcherWidget.isSwipeAnimating == false {
                controller.partnerLocationsView.showIndex(index: input)
                controller.partnerLocationsView.switcherWidget.gotoIndex(index: input)
            }
        }).asObserver()
    }

    var switcherSwipeObserver: AnyObserver<Int> {
        return Binder(base, binding: { (controller: PartnerLocationsViewController, input: Int) in
            controller.partnerLocationsView.showIndex(index: input)
        }).asObserver()
    }

    var switcherDataObserver: AnyObserver<[PartnerVendorItem]> {
        return Binder(base, binding: { (controller: PartnerLocationsViewController, input: [PartnerVendorItem]) in
            controller.partnerLocationsView.addSwitcherData(vendorsItems: input)
        }).asObserver()
    }

    var mapDataObserver: AnyObserver<[PartnerLocationsMarkerData]> {
        return Binder(base, binding: { (controller: PartnerLocationsViewController, input: [PartnerLocationsMarkerData]) in
            controller.partnerLocationsView.addVendorMarkers(markers: input)
        }).asObserver()
    }

}
