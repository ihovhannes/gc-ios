//
// Created by Hovhannes Sukiasian on 30/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import PINRemoteImage
import RxCocoa
import RxSwift
import RxGesture

class PartnerDetailViewController: UIViewController, DisposeBagProvider {

    fileprivate var partnerDetailView: PartnerDetailView {
        return view as? PartnerDetailView ?? PartnerDetailView()
    }

    fileprivate var viewModel: PartnerDetailViewModel!

    init() {
        super.init(nibName: nil, bundle: nil)

        view = PartnerDetailView()
        type = .partnerDetail

        viewModel = PartnerDetailViewModel(bindingsFactory: getBindingsFactory())

        // -- Navigation

        viewModel
                .menuRoutingObservable
                .bind(to: self.rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel
                .sharesRoutingObservable
                .bind(to: self.rx.observerRouting)
                .disposed(by: disposeBag)

        viewModel
                .error
                .map({ ErrorHander.errorToRouting1(error: $0, repeatCallback: nil)})
                .bind(to: self.rx.observerRouting)
                .disposed(by: disposeBag)

        // -- Data source

        viewModel
                .updateDetailsObservable
                .bind(to: self.rx.responseObserver)
                .disposed(by: disposeBag)

        viewModel
                .vendorsObservable
                .bind(to: self.rx.vendorsObserver)
                .disposed(by: disposeBag)

        // --
        partnerDetailView
                .locationButton
                .rx
                .tapGesture()
                .when(.recognized)
                .flatMapLatest({ [unowned self] _ in self.viewModel.locationsRoutingObservable })
                .bind(to: self.rx.observerRouting)
                .disposed(by: disposeBag)


        // -- Error
        viewModel
                .errorObservable
                .subscribe(onNext: nil, onError: { error in
                    log("\(error)")
                })
                .disposed(by: disposeBag)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func configure(id: Int64?, logoSrc: String?, pageColor: String?) -> PartnerDetailViewController {
        let color = UIColor(hex: pageColor)
        viewModel.partnerId.value = id
        viewModel.partnerColor.value = color
        viewModel.partnerLogoSrc.value = logoSrc
        partnerDetailView.configure(logoSrc: logoSrc, pageColor: color)
        return self
    }

}

fileprivate extension PartnerDetailViewController {

    func getBindingsFactory() -> PartnerDetailViewControllerBindingsFactory {
        return { [unowned self] () -> PartnerDetailViewControllerBindings in
            return PartnerDetailViewControllerBindings(
                    appearanceState: self.rx.observableAppearanceState(),
                    drawerButton: DrawerButton.instance.rx.tap.asObservable(),
                    sharesButton: self.partnerDetailView.sharesButton.rx.tapGesture().when(.recognized).map({ _ in () })
            )
        }
    }

}

extension Reactive where Base == PartnerDetailViewController {

    var responseObserver: AnyObserver<PartnerDetailsResponse> {
        return Binder(base, binding: { (controller: PartnerDetailViewController, input: PartnerDetailsResponse) in
            // --
            if input.description != nil || input.photos != nil || input.descriptionVideoSrc != nil {
                controller.partnerDetailView.addDescription(text: input.description, photosSrc: input.photos, descriptionVideoSrc: input.descriptionVideoSrc)
            }

            // --

            if let advantages = input.advantages {
                controller.partnerDetailView.addAdvantages(text: advantages)
            }

            // --

            if let benefits = input.benefits {
                controller.partnerDetailView.addBenefits(text: benefits)
            }

            // --

            if let bonuses = input.bonuses, bonuses.count > 0 {
                controller.partnerDetailView.addBonuses(items: bonuses)
            }

            // --
            controller.partnerDetailView.initTabs()
        }).asObserver()
    }

    var vendorsObserver: AnyObserver<PartnerVendorsResponse> {
        return Binder(base, binding: { (controller: PartnerDetailViewController, input: PartnerVendorsResponse) in
            if let vendors = input.list, vendors.isEmpty == false {
                controller.partnerDetailView.showLocationButton()
            }
        }).asObserver()
    }

}
